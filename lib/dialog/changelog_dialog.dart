import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tool/preferences.dart';

class ChangelogDialog extends StatefulWidget
{
	@override
	State createState() => ChangelogDialogState();
}

class ChangelogDialogState extends State<ChangelogDialog>
{
	var _loading = true;
	
	var _changes = List<dynamic>();
	
	String _version;
	
	void _loadChangelog() async
	{
		final client = http.Client();
		
		_version = (await PackageInfo.fromPlatform()).version;
		
		String response;
		try
		{
			final url = Uri.parse("https://api.github.com/repos/kraxarn/school_schedule/releases");
			response = await client.read(url);
		}
		catch (e)
		{
			setState(() => _loading = false);
			return;
		}
		
		_changes = jsonDecode(response) as List<dynamic>;
		
		setState(() => _loading = false);
	}
	
	@override
	void initState()
	{
		super.initState();
		_loadChangelog();
	}

	final _menuOptions = [
		_buildMenuOption("store", Icons.store),
		_buildMenuOption("code",  Icons.code)
	];

	static PopupMenuItem _buildMenuOption(String value, IconData icon) =>
		PopupMenuItem(
			child: ListTile(
				contentPadding: EdgeInsets.all(0.0),
				leading: Icon(icon),
				title: Text(Preferences.localized("open_$value"))
			),
			value: value,
		);
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text(Preferences.localized("whats_new")),
				actions: <Widget>[
					PopupMenuButton(
						itemBuilder: (context) => _menuOptions,
						onSelected: (value) async
						{
							switch (value)
							{
								case "store":
									await launch("https://play.google.com/store/apps/details?id=com.crow.school_schedule");
									break;
								case "code":
									await launch("https://github.com/kraxarn/school_schedule");
									break;
							}
						},
					)
				],
			),
			body: _loading ? Center(
				child: CircularProgressIndicator()
			) : _changes.isNotEmpty ? ListView(
				children: _changes.map((change) =>
					ExpansionTile(
						initiallyExpanded: (change["name"]) == _version,
						title: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Text(
									change["name"],
									style: change["name"] == _version ? TextStyle(
										fontWeight: FontWeight.bold
									) : null,
								),
								Text(
									(change["published_at"] as String)
										.substring(0,
										(change["published_at"] as String)
											.indexOf('T')),
									style: Theme.of(context).textTheme.caption,
								)
							],
						),
						children: [
							Padding(
								padding: EdgeInsets.only(
									left: 16.0,
									right: 16.0,
									bottom: 16.0
								),
								child: MarkdownBody(
									data: change["body"] as String,
								)
							)
						]
					)).toList(),
			) : Padding(
				padding: EdgeInsets.all(32.0),
				child: Align(
					alignment: Alignment.topCenter,
					child: Text(
						"Connection failed, try again later",
						textAlign: TextAlign.center
					)
				)
			)
		);
}