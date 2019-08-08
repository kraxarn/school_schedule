
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_schedule/school.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
		SharedPreferences.getInstance().then((prefs) {
			prefs.setString("school", schoolId);
			_pushMain(context);
		});
	}
	
	@override
	Widget build(BuildContext context)
	{
		SharedPreferences.getInstance().then((prefs) {
			if (prefs.getString("school") != null)
				_pushMain(context);
		});
		
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