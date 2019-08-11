import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../calendar_event.dart';
import '../preferences.dart';

class SchedulePage extends StatefulWidget
{
	@override
	State createState() =>
		ScheduleState();
}

class ScheduleState extends State<SchedulePage>
{
	final _savedCourses = Preferences.savedCourses;
	
	final _events = List<CalendarEvent>();
	
	/// Reusable HTTP instance for schedule refreshing
	final _http = http.Client();
	
	Widget _buildTitle(ThemeData theme, text)
	{
		return DecoratedBox(
			child: ListTile(
				title: Text(
					text,
					style: theme.textTheme.title,
				),
			
			),
			decoration: BoxDecoration(
				border: Border(
					bottom: Divider.createBorderSide(context)
				)
			),
		);
	}
	
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
	
	TableRow _buildEventInfoRow(String title, String info)
	{
		return TableRow(
			children: [
				Text(
					title,
					style: Theme.of(context).textTheme.subtitle,
				),
				Text(info ?? "(none)")
			]
		);
	}
	
	TableRow _buildEventDivider()
	{
		return TableRow(
			children: [
				Divider(),
				Divider()
			]
		);
	}
	
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
								"Course Name", event.courseId
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
	
	Widget _buildEvent(ThemeData theme, CalendarEvent event)
	{
		return ListTile(
			leading: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Text(
						_weekdayToString(event.start.weekday),
						style: theme.textTheme.caption,
					),
					Text(
						event.start.day.toString()
					)
				],
			),
			title:    Text(event.summary),
			subtitle: Text(
				"${_timeToString(event.start)} - ${_timeToString(event.end)}"
			),
			trailing: Text(
				"${event.courseId.substring(0, event.courseId.indexOf('-'))}\n"
				"${event.location.substring(0, event.location.indexOf(' '))}",
				textAlign: TextAlign.end
			),
			onTap: () {
				_showEventInfo(event);
			},
		);
	}
	
	@override
	void initState()
	{
		super.initState();
		_refreshSchedule(context);
	}
	
	Future<void> _refreshSchedule(BuildContext context) async
	{
		// If no courses saved, do nothing
		if (_savedCourses == null)
		{
			print("Refresh failed: no courses");
			return;
		}
		
		// Get events
		final schoolId = Preferences.school;
		
		// We only set state here if events is empty
		if (_savedCourses == null ||  _savedCourses.isEmpty)
			setState(() {
				_events.clear();
			});
		else
			_events.clear();
		
		for (var course in _savedCourses)
		{
			try
			{
				var cal = await CalendarEvent.getCalendar(_http, schoolId, course);
				final events = CalendarEvent.parseMultiple(cal);
				for (var event in events)
				{
					//event.courseId = course.substring(0, course.indexOf('-'));
					setState(() {
						_events.add(event);
					});
				}
			}
			catch (e)
			{
				print(e);
				return;
			}
		}
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
		// Check if no saved courses
		if (_savedCourses == null || _savedCourses.isEmpty)
			return _buildStatusMessage("No courses found, press the search button to add");
		
		// Check if no events for saved courses
		if (_events.isEmpty)
			return _buildStatusMessage("No events found for saved courses");
		
		// Creates titles for a year
		final events = List<Widget>();
		final now = DateTime.now();
		for (var i = now.month; i <= now.month + 12; i++)
		{
			// Temporary variables
			final year  = i <= 12 ? now.year  : now.year + 1;
			final month = i <= 12 ? i : i % 12;
			
			// Add month title
			events.add(_buildTitle(Theme.of(context), "${_monthToString(month)} $year"));
			
			// Add all events in month
			final monthEvents = _events
				.where((event) => event.start.month == month
					&& event.start.year == year);
			
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
					.add(_buildEvent(Theme.of(context), event)));
			}
		}
		
		return events;
	}
	
	_openSearch() async
	{
		await Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return SearchDialog(_savedCourses);
			},
			fullscreenDialog: true
		));
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			body: RefreshIndicator(
				child: ListView(
					children: _buildEvents()
				),
				onRefresh: () {
					return _refreshSchedule(context);
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
}

class SearchDialog extends StatefulWidget
{
	final List<String> _saved;
	
	@override
	State createState() =>
		SearchState(_saved ?? new List<String>());
	
	SearchDialog(this._saved);
}

class SearchState extends State<SearchDialog>
{
	final _http = http.Client();
	
	/// Title (course code) of all saved
	final List<String> _saved;
	
	/// Map with all results as <title, subtitle>
	final _results = Map<String, String>();
	
	/// If we should show the loading spinner
	var _loading = false;
	
	/// Set school id from preferences
	String _schoolId = Preferences.school;
	
	/// Fix å, ä, ö (kind of hacky, but works)
	String _decode(String text) =>
		text.replaceAll("&#229;", "å")
			.replaceAll("&#228;", "ä")
			.replaceAll("&#246;", "ö");
	
	SearchState(this._saved);
	
	Future<Map<String, String>> _search(String keyword) async
	{
		// TODO: Does nothing if already searching, should cancel
		
		final response = await _http.read(
			"https://webbschema.$_schoolId.se/ajax/ajax_sokResurser.jsp"
			"?sokord=$keyword&startDatum=idag&slutDatum="
			"&intervallTyp=a&intervallAntal=1");
		
		final results = Map<String, String>();
		
		response.substring(
			response.indexOf("resursLista") + 13,
			response.indexOf("</ul>")).split("<li>").forEach((result) {
				if (result.isEmpty || results.length > 20)
					return;
				var r1 = result.substring(result.lastIndexOf("\">") + 2);
				var r2 = r1.substring(0, r1.indexOf("<"));
				var r = r2.split(',');
				//if (r[0].endsWith("-"))
				//	r[0] = r[0].substring(0, r[0].length - 1);
				results.addAll({
					r[0].trim(): _decode(r[1].trim())
				});
		});
		
		return results;
	}
	
	Widget _createResult(String title, String subtitle)
	{
		final _alreadySaved = _saved.contains(title);
		return ListTile(
			title: Text(title.endsWith('-')
				? title.substring(0, title.length - 1) : title),
			subtitle: Text(subtitle),
			trailing: Icon(
				_alreadySaved ? Icons.star : Icons.star_border,
				color: _alreadySaved ? Colors.yellow : null,
			),
			onTap: () {
				setState(() {
					if (_alreadySaved)
						_saved.remove(title);
					else
						_saved.add(title);
					_save();
				});
			},
		);
	}
	
	_save() async => Preferences.savedCourses = _saved;
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			appBar: AppBar(
				title: ListTile(
					title: TextField(
						autofocus: true,
						decoration: InputDecoration(
							hintText: "Search"
						),
						onChanged: (value) {
							setState(() {
								if (value.isEmpty || value.length < 3)
									return;
								_loading = true;
								_results.clear();
								_search(value).then((results) {
									setState(() {
										_results.addAll(results);
									});
									_loading = false;
								});
							});
						},
					),
				)
			),
			body: Column(
				children: <Widget>[
					_loading ? LinearProgressIndicator(
						backgroundColor: Color.fromARGB(0, 0, 0, 0),
					) : SizedBox(),
					Expanded(
						child: ListView(
							children: _results.entries.map((result) {
								return _createResult(result.key, result.value);
							}).toList()
						),
					)
				],
			)
		);
	}
}