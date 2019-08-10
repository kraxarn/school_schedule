import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../calendar_event.dart';

class SchedulePage extends StatefulWidget
{
	@override
	State createState() =>
		ScheduleState();
}

class ScheduleState extends State<SchedulePage>
{
	List<String> _savedCourses;
	
	final _events = List<CalendarEvent>();
	
	_createTitle(ThemeData theme, text)
	{
		return ListTile(
			title: Text(
				text,
				style: theme.textTheme.title,
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
	
	Widget _createEvent(ThemeData theme, CalendarEvent event)
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
				"${event.courseId}\n${event.location}",
				textAlign: TextAlign.end
			),
			onTap: () {
				// TODO: Expand to show some more info
			},
		);
	}
	
	Future<void> _refreshSchedule() async
	{
		// If no courses saved, do nothing
		if (_savedCourses == null)
		{
			print("Refresh failed: no courses");
			return;
		}
		
		// Get events
		final schoolId = (await SharedPreferences.getInstance()).getString("school");
		
		setState(() {
		  _events.clear();
		});
		for (var course in _savedCourses)
		{
			final events = CalendarEvent.parseMultiple(await CalendarEvent.getCalendar(schoolId, course));
			for (var event in events)
			{
				event.courseId = course.substring(0, course.indexOf('-'));
				setState(() {
					_events.add(event);
				});
			}
		}
		return;
	}
	
	_openSearch() async
	{
		await Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return SearchDialog(_savedCourses);
			},
			fullscreenDialog: true
		));
		
		_savedCourses = (await SharedPreferences.getInstance())
			.getStringList("courses");
	}
	
	@override
	Widget build(BuildContext context)
	{
		SharedPreferences.getInstance().then((prefs) {
			_savedCourses = prefs.getStringList("courses");
		});
		
		return Scaffold(
			body: RefreshIndicator(
				child: ListView(
					children: _events.map((event) {
						return _createEvent(Theme.of(context), event);
					}).toList() /*<Widget>[
						Padding(
							padding: EdgeInsets.all(32.0),
							child: Text(
								_savedCourses == null || _savedCourses.isEmpty
									? "No courses found, press the search button to add"
									: "No events found for saved courses",
								textAlign: TextAlign.center,
							),
						),
					],*/
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
	final _saved;
	
	/// Map with all results as <title, subtitle>
	final _results = Map<String, String>();
	
	/// If we should show the loading spinner
	var _loading = false;
	
	/// Set school id from preferences
	String _schoolId;
	
	/// Fix å, ä, ö (kind of hacky, but works)
	String _decode(String text) =>
		text.replaceAll("&#229;", "å")
			.replaceAll("&#228;", "ä")
			.replaceAll("&#246;", "ö");
	
	SearchState(this._saved)
	{
		// Get school ID from preferences when instancing
		SharedPreferences.getInstance().then((prefs) {
			_schoolId = prefs.getString("school");
		});
	}
	
	Future<Map<String, String>> _search(String keyword) async
	{
		final response = await _http.read(
			"http://kronox.$_schoolId.se/ajax/ajax_sokResurser.jsp"
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
	
	_save() async => (await SharedPreferences.getInstance())
			.setStringList("courses", _saved.toList());
	
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