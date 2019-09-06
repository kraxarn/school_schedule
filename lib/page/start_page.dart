import 'package:flutter/material.dart';

import '../tool/preferences.dart';
import '../tool/school.dart';

/// Starting page for choosing school
class StartPage extends StatelessWidget
{
	/// Replace current page with main page
	void _pushMain(BuildContext context) =>
		Navigator.of(context).pushReplacementNamed("/main");
	
	/// Save school to preferences and replace page
	/// (also removes any leftover preferences)
	void _saveSchool(BuildContext context, String schoolId) async
	{
		// Erase old login information
		if (Preferences.username != null)
			Preferences.username = Preferences.password = null;
		
		// Erase old saved courses
		// (We just check to not unnecessarily write null
		if (Preferences.savedCourses != null)
			Preferences.savedCourses = null;
		
		// Save to preferences and go to main page
		Preferences.school = School(schoolId);
		_pushMain(context);
	}
	
	@override
	Widget build(BuildContext context)
	{
		// Just to be sure
		Preferences.buildContext = context;
		
		return Scaffold(
			appBar: AppBar(
				title: Text(Preferences.localized("title_start")),
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