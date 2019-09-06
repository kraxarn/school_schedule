import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../tool/course_name.dart';
import '../tool/preferences.dart';

class SearchDialog extends StatefulWidget
{
	@override
	State createState() => SearchState();
}

class SearchState extends State<SearchDialog>
{
	/// Shared HTTP client for all searches
	final _http = http.Client();
	
	/// Title (course code) of all saved
	final _saved = List<String>();
	
	/// Map with all results as <title, subtitle>
	final _results = Map<String, String>();
	
	/// If we should show the loading spinner
	var _loading = false;
	
	/// If we're entering text, used when building status text
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
	
	/// Perform search and return results
	Future<Map<String, String>> _search(String keyword) async
	{
		// TODO: Does nothing if already searching, should cancel
		
		// Check if using demo
		if (Preferences.school.id == null)
			return null;
		
		final results = Map<String, String>();
		String response;
		
		try
		{
			response = await _http.read(
				"${Preferences.school.baseUrl}ajax/ajax_sokResurser.jsp"
					"?sokord=$keyword&startDatum=idag&slutDatum="
					"&intervallTyp=a&intervallAntal=1"
					"&sprak=${Preferences.locale.locale.languageCode}");
		}
		catch (e)
		{
			return results;
		}
		
		if (!response.contains("resursLista"))
			return results;
		
		response.substring(
			response.indexOf("resursLista") + 13,
			response.indexOf("</ul>")).split("<li>").forEach((result)
		{
			// If no content or we reached max
			if (result.isEmpty || results.length > 20)
				return;
			// Get text between tags
			var r1 = result.substring(result.lastIndexOf("\">") + 2);
			var r2 = r1.substring(0, r1.indexOf("<"));
			var r = r2.split(',');
			// Add to results
			results[r[0].trim()] = _decode(r[1].trim());
		});
		
		return results;
	}
	
	/// Create a result with button to add/remove
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
	
	/// Create centered, padded text if no results
	Widget _buildStatusText() =>
		_enteringText && _results.isEmpty ? Padding(
			padding: EdgeInsets.all(32.0),
			child: Text(Preferences.localized("no_search_results"))
		) : SizedBox();
	
	/// Replace saved courses with temporary list
	void _save() => Preferences.savedCourses = _saved;
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: ListTile(
					title: TextField(
						autofocus: true,
						decoration: InputDecoration(
							hintText: Preferences.localized("search"),
							hintStyle: TextStyle(
								color: Color.fromARGB(128, 255, 255, 255)
							)
						),
						style: TextStyle(
							color: Colors.white,
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
				)
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