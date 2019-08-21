
import 'package:flutter/material.dart';
import 'package:school_schedule/preferences.dart';
import 'package:school_schedule/user_colors.dart';

import '../course_name.dart';
import '../course_settings.dart';

class CourseListDialog extends StatefulWidget
{
	@override
	State createState() => CourseListState();
}

class CourseListState extends State<CourseListDialog>
{
	/// All saved
	final _saved = List<String>();
	
	CourseListState()
	{
		// Check if we have any saved courses
		// (if we try to add null, it crashes)
		if (Preferences.savedCourses != null)
			_saved.addAll(Preferences.savedCourses);
	}
	
	/// Replace saved courses with temporary list
	void _save() => Preferences.savedCourses = _saved;
	
	/// Build a centered and padded message
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
	
	Widget _createColor(Color color, String name)
	{
		return ListTile(
			leading: Container(
				width: 32.0,
				height: 32.0,
				decoration: BoxDecoration(
					shape: BoxShape.circle,
					color: color
				),
			),
			onTap: () => Navigator.of(context).pop(name),
			title: Text(name),
		);
	}
	
	Future<String> _openColorPicker() =>
		showDialog<String>(
			context: context,
			builder: (builder) =>
				SimpleDialog(
					title: Text("Select Color"),
					children: UserColors().colors.map((color) =>
						_createColor(color.baseColor, color.toString())
					).toList()
				)
		);
	
	PopupMenuItem _buildMenuOption(IconData icon, String title, String value) =>
		PopupMenuItem(
			child: ListTile(
				contentPadding: EdgeInsets.all(0.0),
				leading: Icon(icon),
				title: Text(title),
			),
			value: value,
		);
	
	/// Build a result showing a delete button
	Widget _buildResult(String title, String subtitle) =>
		ListTile(
			title: Text(title.endsWith('-')
				? title.substring(0, title.length - 1) : title),
			subtitle: Text(subtitle),
			trailing: IconButton(
				icon: Icon(Icons.delete),
				onPressed: () {
					// TODO: I forgot what I had here
				},
			),
			leading: IconButton(
				icon: Container(
					width: 32.0,
					height: 32.0,
					decoration: BoxDecoration(
						shape: BoxShape.circle,
						color: UserColors().getColor(title).color
					),
				),
				onPressed: () async
				{
					// See if nay color was picked
					final color = await _openColorPicker();
					if (color == null)
						return;
					
					// Get settings for course and find color
					var   settings   = CourseSettings.get(title);
					final colorIndex = UserColor.fromName(color).toIndex();
					
					// If null, we have no settings, create new ones
					// If not, we have other settings, replace color
					if (settings == null)
						settings = CourseSettings(colorIndex);
					else
						settings.color = colorIndex;
					
					// Save new settings
					setState(() => CourseSettings.update(title, settings));
				},
			),
		);
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
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