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
	final _events = List<CalendarEvent>();
	
	/// Reusable HTTP instance for schedule refreshing
	final _http = http.Client();
	
	/// If we're refreshing, used when displaying progress indicator
	var _refreshing = false;
	
	/// When we last refreshed the schedule
	static DateTime _lastRefresh;
	
	/// Subtitle to show
	static String _subtitle;
	
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
	
	/// Get 3 character name of weekday
	String _weekdayToString(int weekday)
	{
		switch (weekday)
		{
			case 1:  return "MON";
			case 2:  return "TUE";
			case 3:  return "WED";
			case 4:  return "THU";
			case 5:  return "FRI";
			case 6:  return "SAT";
			case 7:  return "SUN";
			default: return "???";
		}
	}
	
	/// Get name of month
	String _monthToString(int month)
	{
		switch (month)
		{
			case 1:  return "Janurary";
			case 2:  return "February";
			case 3:  return "March";
			case 4:  return "April";
			case 5:  return "May";
			case 6:  return "June";
			case 7:  return "July";
			case 8:  return "August";
			case 9:  return "September";
			case 10: return "October";
			case 11: return "November";
			case 12: return "December";
			default: return "Unknown";
		}
	}
	
	/// Build table row for event info
	TableRow _buildEventInfoRow(String title, String info) =>
		TableRow(
			children: [
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
				Divider()
			]
		);
	
	/// Show modal sheet for displaying calendar event info
	void _showEventInfo(CalendarEvent event)
	{
		showModalBottomSheet(
			context: context,
			builder: (builder) {
				return Padding(
					padding: EdgeInsets.all(32.0),
					child: Table(
						defaultVerticalAlignment: TableCellVerticalAlignment.middle,
						children: [
							_buildEventInfoRow(
								"Course Code", event.courseId
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								"Course Name",
								CourseName.get(event.fullCourseId) ?? "(none)"
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								"Signature", event.signature
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								"Locations",
								event.location.replaceAll(" ", ", ")
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								"Start",
								DateFormatter.asFullDateTime(event.start)
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								"End",
								DateFormatter.asFullDateTime(event.end)
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								"Last Modified",
								DateFormatter.asFullDateTime(event.lastModified)
							),
						],
					)
				);
			}
		);
	}
	
	/// Get number of months between first day of each month
	int _getMonthsBetween(DateTime from, DateTime to) =>
		((to.year - from.year) * 12) + (to.month - from.month);
	
	/// Refresh the schedule
	Future<void> _refreshSchedule(bool force) async
	{
		// See if refresh was <15 minutes ago
		if (!force && _lastRefresh != null
			&& DateTime.now().difference(_lastRefresh).inMinutes < 15)
			return;
		
		// Test if we're using KronoX demo
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
		
		// Get events
		final school = Preferences.school;
		
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
			await CalendarEvent.getCalendar(_http, school, course)
				.then((cal) =>
					tempEvents.addAll(CalendarEvent.parseMultiple(cal)))
				.catchError((e) => error = true);
		
		// Only set state if current page
		if (MainState.navBarIndex == 0 && tempEvents.isNotEmpty)
		{
			_events.clear();
			setState(() => _events.addAll(tempEvents));
		}
		
		// Check if something went wrong
		// No need to save to cache if error
		if (error)
			Scaffold.of(context).showSnackBar(SnackBar(
				content: Text("Connection failed, try again later"),
			));
		else
		{
			_saveToCache();
			_lastRefresh = DateTime.now();
		}
		
		setState(() => _refreshing = false);
	}
	
	/// Save current event list to cache
	void _saveToCache() async =>
		await File("${(await getTemporaryDirectory()).path}/events.json")
			.writeAsString(jsonEncode(_events.map((event) => event.toJson()).toList()));
	
	/// Loads the current event list from cache
	void _loadFromCache() async
	{
		final file = File("${(await getTemporaryDirectory()).path}/events.json");
		if (!(await file.exists()))
			return;
		final tempEvents = jsonDecode(await file.readAsString()) as List<dynamic>;
		final events = tempEvents.map((value) => CalendarEvent.fromJson(value));
		
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
	
	/// Build a calendar event
	Widget _buildEvent(CalendarEvent event, bool printDate,
		bool isToday, bool highlightTime) =>
		ListTile(
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
			title: Text(
				event.summary,
				style: Preferences.courseColors ? TextStyle(
					color: UserColors().getColor(event.courseId).color
				) : null,
			),
			subtitle: Text(
				"${DateFormatter.asTime(event.start)} - "
					"${DateFormatter.asTime(event.end)}",
				style: TextStyle(
					color: highlightTime ? Colors.red : null,
					fontWeight: _isWithin(DateTime.now(), event)
						? FontWeight.bold : null,
					decoration: event.end.difference(DateTime.now()).isNegative
						? TextDecoration.lineThrough : null
				)
			),
			trailing: Text(
				"${event.courseId.split('-')[0]}\n"
					"${event.location.split(' ')[0]}",
				textAlign: TextAlign.end
			),
			onTap: () => _showEventInfo(event)
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
			return _buildStatusMessage("No courses found, press the search button to add");
		
		// Check if no events for saved courses
		if (_events.isEmpty)
			return _buildStatusMessage("No events found for saved courses");
		
		// Get first and last month for events
		final all = List<CalendarEvent>();
		all.addAll(_events);
		all.sort((e1, e2) => e1.start.compareTo(e2.start));
		
		// Months between first and last event
		final months = _getMonthsBetween(all.first.start, all.last.end);
		
		// Creates titles for a year
		final events = List<Widget>();
		final now = DateTime.now();
		List<CalendarEvent> firstMonth;
		for (var i = all.first.start.month; i <= all.first.start.month + months; i++)
		{
			// Temporary variables
			final year  = i <= 12 ? now.year : now.year + 1;
			final month = i <= 12 ? i : i % 12;
			
			// Add month title
			events.add(_buildTitle("${_monthToString(month)} $year"));
			
			// Add all events in month
			final monthEvents = _events
				.where((event) => event.start.month == month
					&& event.start.year == year).toList();
			monthEvents.sort(((e1, e2) =>
				e1.start.compareTo(e2.start)));
			
			// Check if first month
			if (firstMonth == null)
				firstMonth = monthEvents;
			
			// Insert message if empty
			if (monthEvents.isEmpty)
			{
				events.add(ListTile(
					title: Text(
						"No events for this month",
						style: Theme.of(context).textTheme.caption,
					),
				));
			}
			else
			{
				var lastDate = -1;
				var lastWeek = -1;
				
				//for (final event in monthEvents)
				for (var i = 0; i < monthEvents.length; i++)
				{
					final event = monthEvents[i];
					
					final prev = i > 0
						? monthEvents[i - 1] : null;
					final next = i < monthEvents.length - 1
						? monthEvents[i + 1] : null;
					
					final week = DateFormatter.getWeekNumber(event.start);
					
					if (week != lastWeek && Preferences.showWeek)
						events.add(_buildSubtitle("WEEK $week"));
					
					// Check if it collides with previous or next
					var highlightTime = false;
					if (Preferences.showEventCollision)
						highlightTime = (prev != null
							&& prev.start.day == event.start.day
							&& (_collide(event, prev) || _collide(prev, event)))
							|| (next != null
								&& next.start.day == event.start.day
								&& (_collide(event, next) || _collide(next, event)));
					
					// Add to all events and set parameters
					events.add(_buildEvent(event, event.start.day != lastDate,
						_isSameDay(now, event.start), highlightTime));
					
					// Update for next lap
					lastDate = event.start.day;
					lastWeek = week;
				}
			}
		}
		
		// Update subtitle with events from first month
		// (these are sorted, events are not)
		setState(() => _subtitle = _getSubtitle(firstMonth));
		
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
		
		return "${_monthToString(now.month)} ${now.day}, "
			"${today.length} event${today.length == 1 ? "" : "s"}"
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
				title: _subtitle == null || !Preferences.scheduleToday ?
				Text("Schedule") : Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						SizedBox(
							height: 8.0,
						),
						Text(
							"Schedule",
							style: Theme.of(context).textTheme.title.apply(
								color: Colors.white
							)
						),
						Text(
							_subtitle,
							style: Theme.of(context).textTheme.caption
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