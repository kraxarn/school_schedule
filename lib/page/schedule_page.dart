import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SchedulePage extends StatefulWidget
{
	@override
	State createState() =>
		ScheduleState();
}

class ScheduleState extends State<SchedulePage>
{
	_createTitle(ThemeData theme, text)
	{
		return ListTile(
			title: Text(
				text,
				style: theme.textTheme.title,
			),
		);
	}
	
	_createEvent(ThemeData theme, String day, title, subtitle, info)
	{
		return ListTile(
			leading: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Text(
						day.split(' ')[0],
						style: theme.textTheme.caption,
					),
					Text(
						day.split(' ')[1]
					)
				],
			),
			title:    Text(title),
			subtitle: Text(subtitle),
			trailing: Text(
				info,
				textAlign: TextAlign.end
			),
			onTap: () {},
		);
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			body: ListView(
				children: <Widget>[
					Padding(
						padding: EdgeInsets.all(32.0),
						child: Text(
							"No courses found, press the search button to add",
							textAlign: TextAlign.center,
						),
					),
				],
			),
			floatingActionButton: FloatingActionButton(
				child: Icon(Icons.search),
				onPressed: () {
					Navigator.of(context).push(MaterialPageRoute(
						builder: (builder) {
							return SearchDialog();
						},
						fullscreenDialog: true
					));
				},
				backgroundColor: Theme.of(context).accentColor,
			),
		);
	}
}

class SearchDialog extends StatefulWidget
{
	@override
	State createState() =>
		SearchState();
}

class SearchState extends State<SearchDialog>
{
	final _http = http.Client();
	
	/// Title (course code) of all saved
	final _saved = Set<String>();
	
	/// Map with all results as <title, subtitle>
	final _results = Map<String, String>();
	
	/// If we should show the loading spinner
	var _loading = false;
	
	/// Fix å, ä, ö (kind of hacky, but works)
	String _decode(String text) =>
		text.replaceAll("&#229;", "å")
			.replaceAll("&#228;", "ä")
			.replaceAll("&#246;", "ö");
	
	Future<Map<String, String>> _search(String keyword) async
	{
		// TODO: Make it work with any school
		final response = await _http.read(
			"http://webbschema.mdh.se/ajax/ajax_sokResurser.jsp"
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
				if (r[0].endsWith("-"))
					r[0] = r[0].substring(0, r[0].length - 1);
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
			title: Text(title),
			subtitle: Text(subtitle),
			trailing: Icon(_alreadySaved ? Icons.star : Icons.star_border),
			onTap: () {
				setState(() {
					if (_alreadySaved)
						_saved.remove(title);
					else
						_saved.add(title);
				});
			},
		);
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			appBar: AppBar(
				title: ListTile(
					title: TextField(
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