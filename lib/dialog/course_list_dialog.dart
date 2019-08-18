
import 'package:flutter/material.dart';
import 'package:school_schedule/preferences.dart';

import '../course_name.dart';

class CourseListDialog extends StatefulWidget
{
	@override
	State createState() => CourseListState();
}

class CourseListState extends State<CourseListDialog>
{
	final _saved = List<String>();
	
	CourseListState()
	{
		if (Preferences.savedCourses != null)
			_saved.addAll(Preferences.savedCourses);
	}
	
	void _save() => Preferences.savedCourses = _saved;
	
	List<Widget> _buildStatusMessage(String message) =>
		[
			Padding(
				padding: EdgeInsets.all(32.0),
				child: Text(
					message,
					textAlign: TextAlign.center,
				),
			)
		];
	
	Widget _buildResult(String title, String subtitle)
	{
		return ListTile(
			title: Text(title.endsWith('-')
				? title.substring(0, title.length - 1) : title),
			subtitle: Text(subtitle),
			trailing: IconButton(
				icon: Icon(Icons.delete),
				onPressed: ()
				{
					setState(() => _saved.remove(title));
					_save();
					CourseName.remove(title);
				},
			)
		);
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			appBar: AppBar(
				title: Text("Saved Courses"),
			),
			body: ListView(
				children: _saved.isEmpty
					? _buildStatusMessage("No saved courses found")
					: _saved.map((entry) =>
						_buildResult(entry, CourseName.get(entry))
					).toList()
			),
		);
	}
}