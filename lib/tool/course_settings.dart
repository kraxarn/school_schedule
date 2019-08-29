import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CourseSettings
{
	/// Index in UseColors to use
	int color;
	
	CourseSettings(this.color);
	
	CourseSettings.fromJson(Map<String, dynamic> json) : color = json["color"];
	
	Map<String, dynamic> toJson() =>
		{
			"color": color
		};
	
	/// Map as <courseId, settings>
	static final _courseSettings = Map<String, CourseSettings>();
	
	/// Load course settings from file
	static Future<bool> load() async
	{
		final file = File("${(await getApplicationDocumentsDirectory()).path}/course_settings.json");
		if (!(await file.exists()))
			return false;
		_courseSettings.clear();
		_courseSettings.addAll(
			(jsonDecode(await file.readAsString()) as Map<String, dynamic>)
				.map((key, value) => MapEntry<String, CourseSettings>(key, CourseSettings.fromJson(value))));
		return true;
	}
	
	/// Save course settings to file
	static void _save() async =>
		await File("${(await getApplicationDocumentsDirectory()).path}/course_settings.json")
			.writeAsString(jsonEncode(_courseSettings));
	
	/// Get settings of specified course
	static CourseSettings get(String courseId) =>
		_courseSettings[courseId];
	
	/// Updates course with specified settings
	/// Also works if there are no current settings for the course
	static void update(String courseId, CourseSettings settings)
	{
		if (_courseSettings.containsKey(courseId))
			_courseSettings.remove(courseId);
		
		_courseSettings[courseId] = settings;
		_save();
	}
	
	/// Remove a course settings from list and file
	static void remove(String courseId)
	{
		_courseSettings.remove(courseId);
		_save();
	}
}