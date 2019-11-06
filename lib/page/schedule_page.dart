import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../dialog/search_dialog.dart';
import '../dialog/course_list_dialog.dart';
import '../tool/calendar_event.dart';
import '../tool/preferences.dart';
import '../tool/date_formatter.dart';
import '../tool/event_builder.dart';
import '../demo.dart';
import '../page/main_page.dart';

class SchedulePage extends StatefulWidget
{
	@override
	State createState() => ScheduleState();
}

class ScheduleState extends State<SchedulePage> with WidgetsBindingObserver
{
	/// Shortcut to getting saved courses
	List<String> get _savedCourses => Preferences.savedCourses;
	
	// All events to show in the list
	static final allEvents = List<CalendarEvent>();
	
	/// Reusable HTTP instance for schedule refreshing
	final _http = http.Client();
	
	/// If we're refreshing, used when displaying progress indicator
	var _refreshing = false;
	
	/// When we last refreshed the schedule
	static DateTime _lastRefresh;
	
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
				allEvents.clear();
				allEvents.addAll(Demo.calendarEvents);
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
			setState(() => allEvents.clear());
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
			allEvents.clear();
			setState(() => allEvents.addAll(tempEvents));

			// Sort them to be sorted in cache and when showing later
			allEvents.sort((e1, e2) => e1.start.compareTo(e2.start));
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
		final hiddenEvents = tempEvents.length - allEvents.length;
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
			.writeAsString(jsonEncode(allEvents.map((event) => event.toJson()).toList()));
	
	/// Loads the current event list from cache
	void _loadFromCache() async
	{
		if (allEvents.isNotEmpty)
			return;
		
		final file = File(
			"${(await getTemporaryDirectory()).path}/events.json");
		if (!(await file.exists()))
			return;
		final tempEvents = jsonDecode(
			await file.readAsString()) as List<dynamic>;
		final events = tempEvents.map((value) =>
			CalendarEvent.fromJson(value)).toList();
		
		allEvents.clear();
		setState(() => allEvents.addAll(events));
	}
	
	/// Return if the events have time that collides
	/// (If either e1.start or e1.end is within e2)
	bool _collide(CalendarEvent e1, CalendarEvent e2) =>
		EventBuilder.isWithin(e1.start, e2) || EventBuilder.isWithin(e1.end, e2);
	
	/// Build all events
	List<Widget> _buildEvents()
	{
		if (_refreshing && allEvents.isEmpty)
			return [
				SizedBox()
			];
		
		// Check if no saved courses
		if (Preferences.school.id != null && (_savedCourses == null
			|| _savedCourses.isEmpty))
			return EventBuilder.buildStatusMessage(
				Preferences.localized("no_courses")
			);
		
		// Check if no events for saved courses
		if (allEvents.isEmpty)
			return EventBuilder.buildStatusMessage(
				Preferences.localized("no_events")
			);
		
		// List of all built widgets
		final now    = DateTime.now();
		final events = List<Widget>();
		
		// Temporary variables for use in loop
		var lastDate  = DateTime.utc(0);
		var lastWeek  = -1;
		
		final eventBuilder = EventBuilder(context, this);
		
		// Loop through all events
		for (var i = 0; i < allEvents.length; i++)
		{
			// Get current event
			final event = allEvents[i];
			
			// Check if we should always hide past events
			// or if it's a course we should hide
			if ((Preferences.hidePastEvents
				&& event.end.difference(now).isNegative)
				|| (Preferences.hiddenCourses.any((c) => event.courseId.contains(c))))
				continue;
			
			// Check if duplicate
			final next = i < allEvents.length - 1 ? allEvents[i + 1] : null;
			// If same id as next, it's a duplicate
			if (Preferences.hideDuplicates
				&& next != null && next.id == event.id)
				continue;
			
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
					events.add(eventBuilder.buildDateTitle(newDate));
					
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
				events.add(eventBuilder.buildDateTitle(event.start));
			
			// Week of event
			final week = DateFormatter.getWeekNumber(event.start);
			
			if (week != lastWeek && Preferences.showWeek)
				events.add(eventBuilder.buildSubtitle(
					"${Preferences.localized("week")} $week")
				);
			
			// Previous event (next is fetched earlier)
			final prev = i > 0 ? allEvents[i - 1] : null;
			
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
			events.add(eventBuilder.build(event, event.start.day != lastDate.day,
				EventBuilder.isSameDay(now, event.start), highlightTime));
			
			// Update for next lap
			lastDate = event.start;
			lastWeek = week;
		}
		
		// Another empty event check if all were filtered away
		if (events.isEmpty)
			return EventBuilder.buildStatusMessage(
				Preferences.localized("no_events_filter")
			);
		
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
		
		return "${EventBuilder.weekdayToString(now.weekday)}, "
			"${EventBuilder.monthToString(now.month)} "
			"${now.day}, ${today.length} "
			"${Preferences.localized(today.length == 1 ? "event" : "events")}"
			"${today.length > 0 ? ", ${_getFirstLastTime(today)}" : ""}";
	}
	
	@override
	void initState()
	{
		super.initState();
		WidgetsBinding.instance.addObserver(this);
		_loadFromCache();
		_refreshSchedule(false);
	}
	
	@override
	void dispose()
	{
		// Remove observer for app state
		WidgetsBinding.instance.removeObserver(this);
		super.dispose();
	}
	
	@override
	void didChangeAppLifecycleState(AppLifecycleState state)
	{
		// Refresh schedule if we resumed app
		if (state == AppLifecycleState.resumed)
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
							_getSubtitle(allEvents),
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