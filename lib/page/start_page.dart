import 'package:flutter/material.dart';

import '../preferences.dart';
import '../school.dart';

/// Starting page for choosing school
class StartPage extends StatelessWidget
{
	_pushMain(BuildContext context)
	{
		Navigator.of(context).pushReplacementNamed("/main");
	}
	
	_saveSchool(BuildContext context, String schoolId) async
	{
		// Save to preferences and go to main page
		Preferences.school = schoolId;
		_pushMain(context);
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			appBar: AppBar(
				title: Text("Select School"),
			),
			body: ListView(
				children: School.allSchools.entries.map((school) {
					return ListTile(
						title: Text(school.value),
						onTap: () {
							_saveSchool(context, school.key);
						}
					);
				}).toList()
			),
		);
	}
}