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
	
	/// Formats course ID
	static String getId(String courseId)
	{
		// Find first word
		final s = courseId.indexOf(' ');
		final first = s > 0
			? courseId.substring(0, s).replaceAll(',', '') : courseId;
		// Get until first -
		final i = first.indexOf('-');
		return i > 0 ? first.substring(0, i) : first;
	}
	
	/// Load course settings from file
	static Future<bool> load() async
	{
		final file = File("${(await getApplicationDocumentsDirectory()).path}/course_settings.json");
		if (!(await file.exists()))
			return false;
		_courseSettings.clear();
		_courseSettings.addAll(
			(jsonDecode(await file.readAsString()) as Map<String, dynamic>)
				.map((key, value) =>
					MapEntry<String, CourseSettings>(getId(key),
						CourseSettings.fromJson(value))));
		return true;
	}
	
	/// Save course settings to file
	static void _save() async =>
		await File("${(await getApplicationDocumentsDirectory()).path}/course_settings.json")
			.writeAsString(jsonEncode(_courseSettings));
	
	/// Get settings of specified course
	static CourseSettings get(String courseId) =>
		_courseSettings[getId(courseId)];
	
	/// Updates course with specified settings
	/// Also works if there are no current settings for the course
	static void update(String courseId, CourseSettings settings)
	{
		courseId = getId(courseId);
		
		if (_courseSettings.containsKey(courseId))
			_courseSettings.remove(courseId);
		
		_courseSettings[courseId] = settings;
		_save();
	}
	
	/// Remove a course settings from list and file
	static void remove(String courseId)
	{
		_courseSettings.remove(getId(courseId));
		_save();
	}
}