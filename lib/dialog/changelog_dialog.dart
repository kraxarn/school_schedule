import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

class ChangelogDialog extends StatefulWidget
{
	@override
	State createState() => ChangelogDialogState();
}

class ChangelogDialogState extends State<ChangelogDialog>
{
	String _versionName;
	
	var _loading = true;
	
	String _changelog;
	
	String _releaseDate;
	
	void _loadChangelog() async
	{
		final client = http.Client();
		
		final version = (await PackageInfo.fromPlatform()).version;
		
		
		final response = await client.get(
			"https://api.github.com/repos/kraxarn/school_schedule/"
				"releases/tags/v$version"
		);
		
		// Check if something bad happened
		if (response.statusCode != 200)
			return setState(() => _loading = false);
		
		final json = jsonDecode(response.body);
		_versionName = json["name"];
		_changelog   = json["body"];
		_releaseDate = json["published_at"].toString()
			.replaceAll('T', ' ').replaceAll('Z', '');
		
		setState(() => _loading = false);
	}
	
	@override
	void initState()
	{
		super.initState();
		_loadChangelog();
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text(
					_versionName == null
						? "What's new" : "What's new in version $_versionName"
				)
			),
			body: _loading ? Center(
				child: CircularProgressIndicator()
			) : Scrollbar(
				child: Markdown(
					data: _changelog == null
						? "There was an error fetching the changelog for "
						"your current version. Are you disconnected or using "
						"a developer build?"
						: "Released at $_releaseDate\n\n$_changelog"
				),
			)
		);
}