
import 'package:flutter/material.dart';

import '../tool/preferences.dart';
import '../tool/user_colors.dart';
import '../tool/course_name.dart';
import '../tool/course_settings.dart';

class CourseListDialog extends StatefulWidget
{
	@override
	State createState() => CourseListState();
}

class CourseListState extends State<CourseListDialog>
{
	/// All saved
	final _saved = Preferences.savedCourses;
	
	/// All hidden courses
	final _hidden = Preferences.hiddenCourses;
	
	/// Replace saved courses with temporary list
	void _save() => Preferences.savedCourses = _saved;
	
	/// Replace hidden courses with temporary list
	void _saveHidden() => Preferences.hiddenCourses = _hidden;
	
	final _resultOptions = [
		_buildResultOption("color",  Icons.color_lens),
		_buildResultOption("delete", Icons.delete),
	];
	
	static PopupMenuItem _buildResultOption(String value, IconData icon) =>
		PopupMenuItem(
			child: ListTile(
				contentPadding: EdgeInsets.all(0.0),
				leading: Icon(icon),
				title: Text(Preferences.localized("option_$value"))
			),
			value: value,
		);
	
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
	
	Widget _createColor(Color color, String name) =>
		SimpleDialogOption(
			child: Padding(
				padding: EdgeInsets.all(4.0),
				child: Text(
					name,
					style: TextStyle(
						color: color
					)
				),
			),
			onPressed: () => Navigator.of(context).pop(name),
		);
	
	Future<String> _openColorPicker() =>
		showDialog<String>(
			context: context,
			builder: (builder) =>
				SimpleDialog(
					title: Text(Preferences.localized("select_color")),
					children: UserColors().colors.map((color) =>
						_createColor(color.color, color.toString())
					).toList()
				)
		);
	
	void _selectColor(String title) async
	{
		// See if any color was picked
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
	}
	
	void _showDelete(String title, String subtitle) =>
		showDialog(
			context: context,
			builder: (buildContext) =>
				AlertDialog(
					title: Text(Preferences.localized("delete")),
					content: Text(
						Preferences.localized("delete_course")
							.replaceFirst("{code}", title)
							.replaceFirst("{name}", subtitle)
					),
					actions: <Widget>[
						FlatButton(
							child: Text(Preferences.localized("no")),
							onPressed: () => Navigator.of(context).pop(),
						),
						FlatButton(
							child: Text(Preferences.localized("yes")),
							onPressed: ()
							{
								Navigator.of(context).pop();
								setState(() => _saved.remove(title));
								_save();
								CourseName.remove(title);
								CourseSettings.remove(title);
							},
						)
					],
				)
		);
	
	/// Build a result showing a delete button
	Widget _buildResult(String title, String subtitle) =>
		PopupMenuButton(
			offset: Offset.fromDirection(0.0),
			itemBuilder: (builder) => _resultOptions,
			onSelected: (value) async
			{
				switch (value)
				{
					case "color":
						_selectColor(title);
						break;
					case "delete":
						_showDelete(title, subtitle);
						break;
				}
			},
			child: ListTile(
				title: Text(
					title.endsWith('-')
						? title.substring(0, title.length - 1) : title,
					style: TextStyle(
						color: UserColors().getColor(title).color
					),
				),
				subtitle: Text(subtitle),
				trailing: Icon(Icons.more_vert),
				leading: Checkbox(
					activeColor: Colors.cyan[700],
					value: !_hidden.contains(title),
					onChanged: (value)
					{
						setState(() => _hidden.contains(title)
							? _hidden.remove(title) : _hidden.add(title));
						_saveHidden();
					},
				),
			)
		);
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text(Preferences.localized("title_saved_courses")),
			),
			body: ListView(
				children: _saved.isEmpty
					? _buildStatusMessage(Preferences.localized("no_saved_courses"))
					: _saved.map((entry) =>
						_buildResult(entry, CourseName.get(entry))
					).toList()
			),
		);
}