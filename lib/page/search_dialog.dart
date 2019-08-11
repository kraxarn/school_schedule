import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../preferences.dart';

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