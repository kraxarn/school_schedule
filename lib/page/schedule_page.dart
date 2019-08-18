import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../calendar_event.dart';
import '../preferences.dart';
import '../dialog/search_dialog.dart';
import '../course_name.dart';
import '../demo.dart';

class SchedulePage extends StatefulWidget
{
	@override
	State createState() =>
		ScheduleState();
}

class ScheduleState extends State<SchedulePage>
{
	List<String> get _savedCourses => Preferences.savedCourses;
	
	final _events = List<CalendarEvent>();
	
	/// Reusable HTTP instance for schedule refreshing
	final _http = http.Client();
	
	var _refreshing = false;
	
	Widget _buildTitle(text) =>
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
	
	String _timeToString(DateTime time)
	{
		final hours   = time.hour   < 10 ? "0${time.hour}"   : "${time.hour}";
		final minutes = time.minute < 10 ? "0${time.minute}" : "${time.minute}";
		return "$hours:$minutes";
	}
	
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
	
	TableRow _buildEventDivider() =>
		TableRow(
			children: [
				Divider(),
				Divider()
			]
		);
	
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
								"Start", event.start.toString()
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								"End", event.end.toString()
							),
						],
					)
				);
			}
		);
	}
	
	int _getMonthsBetween(DateTime from, DateTime to) =>
		((to.year - from.year) * 12) + (to.month - from.month);
	
	Widget _buildEvent(CalendarEvent event) =>
		ListTile(
			leading: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Text(
						_weekdayToString(event.start.weekday),
						style: Theme.of(context).textTheme.caption,
					),
					Text(event.start.day.toString())
				],
			),
			title:    Text(event.summary),
			subtitle: Text(
				"${_timeToString(event.start)} - ${_timeToString(event.end)}"
			),
			trailing: Text(
				"${event.courseId.split('-')[0]}\n"
				"${event.location.split(' ')[0]}",
				textAlign: TextAlign.end
			),
			onTap: () => _showEventInfo(event)
		);
	
	Future<void> _refreshSchedule() async
	{
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
		
		for (var course in _savedCourses)
		{
			try
			{
				var cal = await CalendarEvent.getCalendar(_http, school, course);
				tempEvents.addAll(CalendarEvent.parseMultiple(cal));
			}
			catch (e)
			{
				print(e);
				return;
			}
		}
		
		_events.clear();
		setState(() => _events.addAll(tempEvents));
		_refreshing = false;
		_saveToCache();
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
	
	_buildStatusMessage(String text) =>
		[
			Padding(
				padding: EdgeInsets.all(32.0),
				child: Text(
					text,
					textAlign: TextAlign.center,
				)
			)
		];
	
	List<Widget> _buildEvents()
	{
		if (_refreshing && _events.isEmpty)
			return [
				SizedBox()
			];
		
		// Check if no saved courses
		if (_savedCourses == null || _savedCourses.isEmpty)
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
				monthEvents
					.forEach((event) => events
					.add(_buildEvent(event)));
			}
		}
		
		return events;
	}
	
	_openSearch() async
	{
		await Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return SearchDialog();
			},
			fullscreenDialog: true
		));
		_refreshSchedule();
	}
	
	@override
	void initState()
	{
		super.initState();
		_loadFromCache();
		_refreshSchedule();
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
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
				onRefresh: () {
					return _refreshSchedule();
				},
			),
			floatingActionButton: FloatingActionButton(
				child: Icon(Icons.search),
				onPressed: () {
					_openSearch();
				},
				backgroundColor: Theme.of(context).accentColor,
			)
		);
}