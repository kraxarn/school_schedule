import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:school_schedule/course_name.dart';

import '../preferences.dart';
import 'course_list_dialog.dart';

class SearchDialog extends StatefulWidget
{
	@override
	State createState() => SearchState();
}

class SearchState extends State<SearchDialog>
{
	final _http = http.Client();
	
	/// Title (course code) of all saved
	final _saved = List<String>();
	
	/// Map with all results as <title, subtitle>
	final _results = Map<String, String>();
	
	/// If we should show the loading spinner
	var _loading = false;
	
	var _enteringText = false;
	
	SearchState()
	{
		if (Preferences.savedCourses != null)
			_saved.addAll(Preferences.savedCourses);
	}
	
	/// Fix å, ä, ö (kind of hacky, but works)
	String _decode(String text) =>
		text.replaceAll("&#229;", "å")
			.replaceAll("&#228;", "ä")
			.replaceAll("&#246;", "ö");
	
	Future<Map<String, String>> _search(String keyword) async
	{
		// TODO: Does nothing if already searching, should cancel
		
		final response = await _http.read(
			"${Preferences.school.baseUrl}ajax/ajax_sokResurser.jsp"
				"?sokord=$keyword&startDatum=idag&slutDatum="
				"&intervallTyp=a&intervallAntal=1");
		
		final results = Map<String, String>();
		
		if (!response.contains("resursLista"))
			return results;
		
		response.substring(
			response.indexOf("resursLista") + 13,
			response.indexOf("</ul>")).split("<li>").forEach((result) {
			if (result.isEmpty || results.length > 20)
				return;
			var r1 = result.substring(result.lastIndexOf("\">") + 2);
			var r2 = r1.substring(0, r1.indexOf("<"));
			var r = r2.split(',');
			results.addAll({
				r[0].trim(): _decode(r[1].trim())
			});
		});
		
		return results;
	}
	
	/// Testing search with HTML parser
	/// (don't use, about 100-200 ms slower)
	Future<Map<String, String>> _searchHtml(String keyword) async
	{
		final response = await _http.read(
			"${Preferences.school.baseUrl}ajax/ajax_sokResurser.jsp"
				"?sokord=$keyword&startDatum=idag&slutDatum="
				"&intervallTyp=a&intervallAntal=1");
		
		final results = parse(response).firstChild.children[1].children
			.firstWhere((child) => child.className == "resursLista").children;
		
		final courses = Map<String, String>();
		
		for (final result in results)
		{
			if (courses.length > 20)
				break;
			
			final content = result.firstChild.firstChild.text.split(',');
			courses[content[0].trim()] = _decode(content[1].trim());
		}
		
		return courses;
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
				color: _alreadySaved ? Colors.orange : null,
			),
			onTap: ()
			{
				setState(() =>
					_alreadySaved ? _saved.remove(title) : _saved.add(title));
				_save();
				
				// Save to course name
				// (this is unrelated to widget state)
				if (_alreadySaved)
					CourseName.remove(title);
				else
					CourseName.add(title, subtitle);
			},
		);
	}
	
	Widget _buildStatusText() =>
		_enteringText && _results.isEmpty ? Padding(
			padding: EdgeInsets.all(32.0),
			child: Text("No results found")
		) : SizedBox();
	
	_save() => Preferences.savedCourses = _saved;
	
	_openCourseList() async =>
		await Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return CourseListDialog();
			},
			fullscreenDialog: true
		));
	
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
							_enteringText = value.length > 3;
						},
						onSubmitted: (value) {
							setState(()
							{
								if (value.isEmpty || value.length < 3)
									return;
								_loading = true;
								_results.clear();
								_search(value).then((results) {
									setState(() => _results.addAll(results));
									_loading = false;
								});
							});
						},
					),
				),
				actions: <Widget>[
					IconButton(
						icon: Icon(Icons.list),
						onPressed: () => _openCourseList(),
					)
				],
			),
			body: Column(
				children: <Widget>[
					_loading ? LinearProgressIndicator(
						backgroundColor: Color.fromARGB(0, 0, 0, 0),
					) : _buildStatusText(),
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