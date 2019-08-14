import 'package:school_schedule/course_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application preferences
class Preferences
{
	/// Shortcut for SharedPreference.getInstance()
	static Future<SharedPreferences> get _prefs =>
		SharedPreferences.getInstance();
	
	/// Selected school
	static String _school;
	static String get school => _school;
	static set school(String value)
	{
		_school = value;
		_prefs.then((prefs) => prefs.setString("school", value));
	}
	
	/// Saved courses
	static List<String> _savedCourses;
	static List<String> get savedCourses => _savedCourses;
	static set savedCourses(List<String> values)
	{
		_savedCourses = values;
		_prefs.then((prefs) => prefs.setStringList("courses", values));
	}
	
	/// If dark mode is enabled
	static bool _darkMode;
	static bool get darkMode => _darkMode;
	static set darkMode(bool value)
	{
		_darkMode = value;
		_prefs.then((prefs) =>
			prefs.setString("theme", value ? "dark" : "light"));
	}
	
	/// If we should sync with device calendar
	static bool _deviceSync;
	static bool get deviceSync => _deviceSync ?? false;
	static set deviceSync(bool value)
	{
		_deviceSync = value;
		_prefs.then((prefs) => prefs.setBool("device_sync", value));
	}
	
	/// School login ID
	static String _accountId;
	static String get accountId => _accountId;
	static set accountId(String value)
	{
		_accountId = value;
		_prefs.then((prefs) => prefs.setString("account", value));
	}
	
	/// Google account ID
	/*static String _googleId;
	static String get googleId => _googleId;
	static set googleId(String value)
	{
		_googleId = value;
		_prefs.then((prefs) => prefs.setString("google", value));
	}*/
	
	/// Sync calendar with Google
	static bool _googleSync;
	static bool get googleSync => _googleSync ?? false;
	static set googleSync(bool value)
	{
		_googleSync = value;
		_prefs.then((prefs) => prefs.setBool("google_sync", value));
	}
	
	static Future<bool> create() async
	{
		var prefs = await SharedPreferences.getInstance();
		_school       = prefs.getString("school");
		_savedCourses = prefs.getStringList("courses");
		_darkMode     = prefs.getString("theme") == "dark";
		_deviceSync   = prefs.getBool("device_sync");
		_accountId    = prefs.getString("account");
		_googleSync   = prefs.getBool("google_sync");
		
		await CourseName.load();
		return true;
	}
}