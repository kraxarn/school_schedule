import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../dialog/search_dialog.dart';
import '../dialog/course_list_dialog.dart';
import '../tool/calendar_event.dart';
import '../tool/preferences.dart';
import '../tool/course_name.dart';
import '../tool/date_formatter.dart';
import '../tool/user_colors.dart';
import '../demo.dart';
import '../page/main_page.dart';


class SchedulePage extends StatefulWidget
{
	@override
	State createState() =>
		ScheduleState();
}

class ScheduleState extends State<SchedulePage>
{
	/// Shortcut to getting saved courses
	List<String> get _savedCourses => Preferences.savedCourses;
	
	// All events to show in the list
	static final _events = List<CalendarEvent>();
	
	/// Reusable HTTP instance for schedule refreshing
	final _http = http.Client();
	
	/// If we're refreshing, used when displaying progress indicator
	var _refreshing = false;
	
	/// When we last refreshed the schedule
	static DateTime _lastRefresh;
	
	/// Build title with bottom border
	Widget _buildTitle(String text) =>
		DecoratedBox(
			child: ListTile(
				title: Text(
					text,
					style: Theme.of(context).textTheme.title,
				),
			
			),
			decoration: BoxDecoration(
				border: Border(
					bottom: Divider.createBorderSide(context)
				)
			),
		);
	
	/// Build a title with month and year
	Widget _buildDateTitle(DateTime date) =>
		_buildTitle(
			"${_monthToString(date.month)} ${date.year}"
		);
		
	/// Get 3 character name of weekday
	String _weekdayToString(int weekday) =>
		Preferences.localized("week_days").split(',')[weekday - 1];
	
	/// Get name of month
	String _monthToString(int month) =>
		Preferences.localized("months").split(',')[month - 1];
	
	/// Build table row for event info
	TableRow _buildEventInfoRow(IconData icon, String title, String info) =>
		TableRow(
			children: [
				Icon(icon),
				Text(
					title,
					style: Theme.of(context).textTheme.subtitle,
				),
				Text(info ?? "(none)")
			]
		);
	
	/// Build an empty table row
	TableRow _buildEventDivider() =>
		TableRow(
			children: [
				Divider(),
				Divider(),
				Divider()
			]
		);
	
	/// Refresh the schedule
	Future<void> _refreshSchedule(bool force) async
	{
		// See if refresh was <15 minutes ago
		if (!force && _lastRefresh != null
			&& DateTime.now().difference(_lastRefresh).inMinutes < 15)
			return;
		
		// Check if we're using demo school
		if (Preferences.school.id == null)
		{
			setState(() {
				_events.clear();
				_events.addAll(Demo.calendarEvents);
			});
			return;
		}
		
		// If no courses saved, do nothing
		if (_savedCourses == null)
			return;
		
		_refreshing = true;

		// We only set state here if events is empty
		if (_savedCourses == null ||  _savedCourses.isEmpty)
		{
			setState(() => _events.clear());
			_refreshing = false;
			return;
		}
		
		final tempEvents = List<CalendarEvent>();
		var error = false;
		
		// Get events four courses and save to tempEvents
		for (var course in _savedCourses)
			await CalendarEvent.getCalendar(_http, Preferences.school, course)
				.then((cal) =>
					tempEvents.addAll(CalendarEvent.parseMultiple(cal)))
				.catchError((e) => error = true);
		
		// Only set state if current page
		if (MainState.navBarIndex == 0 && tempEvents.isNotEmpty)
		{
			_events.clear();
			setState(() => _events.addAll(tempEvents));

			// Sort them to be sorted in cache and when showing later
			_events.sort((e1, e2) => e1.start.compareTo(e2.start));
		}
		
		// Check if something went wrong
		// No need to save to cache if error
		if (error)
			Scaffold.of(context).showSnackBar(SnackBar(
				content: Text(Preferences.localized("connection_failed")),
			));
		else
		{
			_saveToCache();
			_lastRefresh = DateTime.now();
		}
		
		// Check if any events got filtered
		final hiddenEvents = tempEvents.length - _events.length;
		if (hiddenEvents > 0)
			Scaffold.of(context).showSnackBar(SnackBar(
				content: Text(Preferences.localized(hiddenEvents == 1
					? "hiding_event" : "hiding_events")
					.replaceFirst("{events}", "$hiddenEvents")),
				duration: Duration(seconds: 2)
			));
		
		setState(() => _refreshing = false);
	}
	
	/// Save current event list to cache
	void _saveToCache() async =>
		await File("${(await getTemporaryDirectory()).path}/events.json")
			.writeAsString(jsonEncode(_events.map((event) => event.toJson()).toList()));
	
	/// Loads the current event list from cache
	void _loadFromCache() async
	{
		if (_events.isNotEmpty)
			return;
		
		final file = File(
			"${(await getTemporaryDirectory()).path}/events.json");
		if (!(await file.exists()))
			return;
		final tempEvents = jsonDecode(
			await file.readAsString()) as List<dynamic>;
		final events = tempEvents.map((value) =>
			CalendarEvent.fromJson(value)).toList();
		
		_events.clear();
		setState(() => _events.addAll(events));
	}
	
	/// Build centered and padded status message
	List<Widget> _buildStatusMessage(String text) =>
		[
			Padding(
				padding: EdgeInsets.all(32.0),
				child: Text(
					text,
					textAlign: TextAlign.center,
				)
			)
		];
	
	Widget _buildSubtitle(String text) =>
		Padding (
			padding: EdgeInsets.only(
				left: 72.0,
				top: 8.0,
				bottom: 8.0
			),
			child: Text(
				text,
				style: Theme.of(context).textTheme.caption,
				
			)
		);
	
	bool _isSameDay(DateTime d1, DateTime d2) =>
		d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
	
	String _getDaysTo(DateTime d1, DateTime d2)
	{
		final diff  = d1.difference(d2);
		final days  = diff.inDays;
		final hours = diff.inHours;
		
		if (days != 0)
			return "${Preferences.localized(days > 0
				? "time_in" : "time_was_ago").replaceFirst("{time}",
				"${days < 0 ? -days : days} ${Preferences.localized(
					days == 1 ? "day" : "days").toLowerCase()}")}";
		
		return "${Preferences.localized(hours > 0
			? "time_in" : "time_was_ago").replaceFirst("{time}",
			"${hours < 0 ? -hours : hours} ${Preferences.localized(
				hours == 1 ? "hour" : "hours")}")}";
	}
	
	/// Build a calendar event
	Widget _buildEvent(CalendarEvent event, bool printDate,
		bool isToday, bool highlightTime) =>
		ExpansionTile(
			leading: printDate ? Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Text(
						_weekdayToString(event.start.weekday),
						style: Theme.of(context).textTheme.caption.copyWith(
							color: isToday ? Theme.of(context).accentColor : null
						),
					),
					Text(
						event.start.day.toString(),
						style: TextStyle(
							color: isToday ? Theme.of(context).accentColor : null
						),
					)
				],
				
			) : SizedBox(),
			title: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					// Title
					Text(
						event.summary,
						style: Preferences.courseColors ? TextStyle(
							color: UserColors().getColor(event.courseId).color
						) : null,
					),
					// Subtitle
					Text(
						"${DateFormatter.asTime(event.start)} - "
							"${DateFormatter.asTime(event.end)}",
						style: Theme.of(context).textTheme.caption.copyWith(
							color: highlightTime ? Colors.red : null,
							fontWeight: _isWithin(DateTime.now(), event)
								? FontWeight.bold : null,
							decoration: event.end.difference(DateTime.now()).isNegative
								? TextDecoration.lineThrough : null
						),
					)
				],
			),
			trailing: Text(
				"${event.courseId.split('-')[0]}\n"
					"${event.location.split(' ')[0]}",
				textAlign: TextAlign.end
			),
			children: <Widget>[
				Padding(
					padding: EdgeInsets.all(16.0),
					child: Table(
						defaultVerticalAlignment: TableCellVerticalAlignment.middle,
						columnWidths: {
							0: FixedColumnWidth(48.0)
						},
						children: [
							_buildEventInfoRow(
								Icons.school,
								Preferences.localized("course_code"),
								event.courseId
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.text_fields,
								Preferences.localized("course_name"),
								CourseName.get(event.fullCourseId)
									?? Preferences.localized("none")
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.account_circle,
								Preferences.localized("signature"),
								event.signature
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.location_on,
								Preferences.localized("locations"),
								event.location.isEmpty
									? Preferences.localized("none")
									: event.location.replaceAll(" ", ", ")
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.timelapse,
								Preferences.localized("date_time"),
								"${DateFormatter.asFullDateTime(event.start)} - "
									"${_isSameDay(event.start, event.end)
									? DateFormatter.asTime(event.end)
									: DateFormatter.asFullDateTime(event.end)}\n(${_getDaysTo(event.start, DateTime.now())})"
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.edit,
								Preferences.localized("last_modified"),
								DateFormatter.asFullDateTime(event.lastModified)
							)
						]
					)
				)
			]
		);
	
	/// If the date occurs within the event
	bool _isWithin(DateTime date, CalendarEvent event) =>
		event.start.difference(date).isNegative
			&& !event.end.difference(date).isNegative;
	
	/// Return if the events have time that collides
	/// (If either e1.start or e1.end is within e2)
	bool _collide(CalendarEvent e1, CalendarEvent e2) =>
		_isWithin(e1.start, e2) || _isWithin(e1.end, e2);
	
	/// Build all events
	List<Widget> _buildEvents()
	{
		if (_refreshing && _events.isEmpty)
			return [
				SizedBox()
			];
		
		// Check if no saved courses
		if (Preferences.school.id != null && (_savedCourses == null || _savedCourses.isEmpty))
			return _buildStatusMessage(Preferences.localized("no_courses"));
		
		// Check if no events for saved courses
		if (_events.isEmpty)
			return _buildStatusMessage(Preferences.localized("no_events"));
		
		// List of all built widgets
		final now    = DateTime.now();
		final events = List<Widget>();
		
		// Temporary variables for use in loop
		var lastDate  = DateTime.utc(0);
		var lastWeek  = -1;
		
		// List of all event IDs for filtering duplicates
		final eventIds = HashSet<String>();
		
		// Loop through all events
		for (var i = 0; i < _events.length; i++)
		{
			// Get current event
			final event = _events[i];
			
			// Check if we should always hide past events
			// or if it's a course we should hide
			if ((Preferences.hidePastEvents
				&& event.end.difference(now).isNegative)
				|| (Preferences.hiddenCourses.contains(event.courseId)))
				continue;
			
			// Check if duplicate
			if (Preferences.hideDuplicates)
			{
				// If in set, continue
				if (event.id != null && eventIds.contains(event.id))
					continue;
				
				// Add event to list of events
				eventIds.add(event.id);
			}
			
			// Check if we skipped a month
			if (lastDate.month - event.start.month > 1)
			{
				// Get exact months difference
				var diff = (((event.start.year - lastDate.year) * 12)
					+ event.start.month - lastDate.month);
				
				// Keep adding new months
				while (--diff > 0)
				{
					// Get the new date with the month reduced
					final newMonth = event.start.month - diff;
					final newDate = DateTime(
						event.start.year + (newMonth < 0 ? 1 : 0),
						newMonth < 0 ? (newMonth + 12) : newMonth
					);
					
					// Add month title
					events.add(_buildDateTitle(newDate));
					
					// Add "no events for this month"
					events.add(ListTile(
						title: Text(
							Preferences.localized("no_events_month"),
							style: Theme.of(context).textTheme.caption,
						),
					));
				}
			}
			
			// Check if new month
			if (lastDate.month != event.start.month
				|| lastDate.year != event.start.year)
				events.add(_buildDateTitle(event.start));
			
			// Week of event
			final week = DateFormatter.getWeekNumber(event.start);
			
			if (week != lastWeek && Preferences.showWeek)
				events.add(_buildSubtitle(
					"${Preferences.localized("week")} $week")
				);
			
			// Previous and next events (if any)
			final prev = i > 0 ? _events[i - 1] : null;
			final next = i < _events.length - 1 ? _events[i + 1] : null;
			
			// Check if it collides with previous or next
			var highlightTime = false;
			if (Preferences.showEventCollision)
				highlightTime = (prev != null
					&& prev.start.day == event.start.day
					&& (_collide(event, prev) || _collide(prev, event)))
					|| (next != null
						&& next.start.day == event.start.day
						&& (_collide(event, next) || _collide(next, event))
						&& (!Preferences.hideDuplicates || event.id != next.id));
			
			// Add to all events and set parameters
			events.add(_buildEvent(event, event.start.day != lastDate.day,
				_isSameDay(now, event.start), highlightTime));
			
			// Update for next lap
			lastDate = event.start;
			lastWeek = week;
		}
		
		// Return final widget list
		return events;
	}
	
	/// Open a dialog and refresh schedule after close
	void _openFullscreenDialog(Widget Function(BuildContext) dialogBuilder) async
	{
		await Navigator.of(context).push(MaterialPageRoute(
			builder: dialogBuilder,
			fullscreenDialog: true
		));
		_refreshSchedule(true);
	}
	
	/// Open search dialog
	void _openSearch() =>
		_openFullscreenDialog((context) => SearchDialog());
	
	/// Opens the course list dialog
	void _openCourseList() =>
		_openFullscreenDialog((context) => CourseListDialog());
	
	/// Gets the time of the first and last event in list
	/// (assumes events are sorted)
	String _getFirstLastTime(List<CalendarEvent> events) =>
		"${DateFormatter.asTime(events.first.start)} - "
			"${DateFormatter.asTime(events.last.end)}";
	
	/// Gets all events for today
	/// (assumes events are sorted)
	List<CalendarEvent> _getEventsToday(List<CalendarEvent> events, DateTime date)
	{
		// To make it slightly faster than just a filter,
		// we stop after we reach another day other than today
		
		final today = List<CalendarEvent>();
		for (final event in events)
		{
			if (event.start.year     != date.year
				|| event.start.month != date.month
				|| event.start.day   != date.day)
				return today;
			
			today.add(event);
		}
		
		return today;
	}
	
	String _getSubtitle(List<CalendarEvent> events)
	{
		// $month $day, $numEvents events, $firstTime - $lastTime
		
		final now   = DateTime.now();
		final today = _getEventsToday(events, now);
		
		return "${_weekdayToString(now.weekday)}, ${_monthToString(now.month)} "
			"${now.day}, ${today.length} "
			"${Preferences.localized(today.length == 1 ? "event" : "events")}"
			"${today.length > 0 ? ", ${_getFirstLastTime(today)}" : ""}";
	}
	
	@override
	void initState()
	{
		super.initState();
		_loadFromCache();
		_refreshSchedule(false);
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						SizedBox(
							height: 8.0,
						),
						Text(
							Preferences.localized("title_schedule"),
							style: Theme.of(context).textTheme.title.apply(
								color: Colors.white
							)
						),
						Text(
							_getSubtitle(_events),
							style: Theme.of(context).textTheme.caption.apply(
								// It's in the title, so always light color
								color: ThemeData.dark().textTheme.caption.color
							)
						)
					],
				),
				actions: <Widget>[
					IconButton(
						icon: Icon(Icons.list),
						onPressed: () => _openCourseList(),
					),
					IconButton(
						icon: Icon(Icons.search),
						onPressed: () => _openSearch()
					)
				],
			),
			body: RefreshIndicator(
				child: Column(
					children: <Widget>[
						_refreshing ? LinearProgressIndicator(
							backgroundColor: Color.fromARGB(0, 0, 0, 0),
						) : SizedBox(),
						Expanded(
							child: ListView(
								children: _buildEvents()
							),
						)
					],
				),
				onRefresh: () => _refreshSchedule(true),
			)
		);
}