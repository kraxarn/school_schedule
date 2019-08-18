import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CourseName
{
	/// List of all known course names
	static final _courseNames = Map<String, String>();
	
	/// Load course names from file
	static Future<bool> load() async
	{
		final file = File("${(await getApplicationDocumentsDirectory()).path}/course_names.json");
		if (!(await file.exists()))
			return false;
		_courseNames.clear();
		_courseNames.addAll(
			(jsonDecode(await file.readAsString()) as Map<String, dynamic>)
				.map((key, value) => MapEntry<String, String>(key, value)));
		return true;
	}
	
	/// Save course names to file
	static void _save() async =>
		await File("${(await getApplicationDocumentsDirectory()).path}/course_names.json")
			.writeAsString(jsonEncode(_courseNames));
	
	/// Get name of specified course
	static String get(String courseId) =>
		_courseNames[courseId];
	
	/// Add a course and name to the list and save to file
	static void add(String courseId, String courseName)
	{
		_courseNames[courseId] = courseName;
		_save();
	}
	
	/// Remove a course name from list and file
	static void remove(String courseId)
	{
		_courseNames.remove(courseId);
		_save();
	}
}