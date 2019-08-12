import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CourseName
{
	static final _courseNames = Map<String, String>();
	
	static Future<bool> load() async
	{
		final file = File("${(await getApplicationDocumentsDirectory()).path}/course_names.json");
		if (!(await file.exists()))
			return false;
		_courseNames.clear();
		_courseNames.addAll(jsonDecode(await file.readAsString()));
		return true;
	}
	
	static void _save() async =>
		await File("${(await getApplicationDocumentsDirectory()).path}/course_names.json")
			.writeAsString(jsonEncode(_courseNames));
	
	static String get(String courseId) =>
		_courseNames[courseId];
	
	static void add(String courseId, String courseName)
	{
		_courseNames[courseId] = courseName;
		_save();
	}
	
	static void remove(String courseId)
	{
		_courseNames.remove(courseId);
		_save();
	}
}