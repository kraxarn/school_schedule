import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

import 'account.dart';
import 'course_name.dart';
import 'school.dart';

/// Application preferences
class Preferences
{
	/// Shortcut for SharedPreference.getInstance()
	static Future<SharedPreferences> get _prefs =>
		SharedPreferences.getInstance();
	
	static String _uniqueId;
	
	/// Selected school
	static School _school;
	static School get school => _school;
	static set school(School value)
	{
		_school = value;
		_prefs.then((prefs) => prefs.setString("school", value.id));
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
	
	/// How often to refresh in the background
	static int _refreshInterval;
	static int get refreshInterval => _refreshInterval ?? 60;
	static set refreshInterval(int value)
	{
		_refreshInterval = value;
		_prefs.then((prefs) => prefs.setInt("refresh_interval", value));
	}
	
	/// Last refresh of session
	static DateTime _sessionRefresh = DateTime.now();
	
	/// School login ID
	static String _sessionId;
	static Future<String> get sessionId async
	{
		// Invalidate if older than 20 minutes
		if (DateTime.now().difference(_sessionRefresh).inMinutes > 20)
			_sessionId = null;
		
		if (_sessionId == null)
		{
			// Get new session
			final http = HttpClient();
			_sessionId = (await Account.getSession(http)).value;
			
			// Update refresh time
			_sessionRefresh = DateTime.now();
			
			// Also login if saved
			if (username != null && password != null)
				if ((await Account.login(http, username, password)) == null)
					print("warning: login failed");
		}
		return _sessionId;
	}
	static Future<Cookie> get sessionCookie async =>
		Cookie("JSESSIONID", await sessionId);
	
	/// User's username
	static String _username;
	static String get username => _username;
	static set username(String value)
	{
		_username = value;
		_prefs.then((prefs) => prefs.setString("username", value));
	}
	
	static String _password;
	static String get password => _password;
	static set password(String value)
	{
		// Password is kept unencrypted in memory
		_password = value;
		// Encrypted in storage
		_prefs.then((prefs) => prefs.setString("password",
			value == null ? null : _encrypt(value)));
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
	
	/// Last used location for booking
	static String _lastLocation;
	static String get lastLocation => _lastLocation;
	static set lastLocation(String value)
	{
		_lastLocation = value;
		_prefs.then((prefs) => prefs.setString("last_location", value));
	}
	
	/// Get default encrypter
	static Encrypter get _encrypter =>
		Encrypter(AES(Key.fromUtf8(_uniqueId)));
	
	/// Get default IV (init vector)
	static IV get _iv => IV.fromLength(16);
	
	static String _encrypt(String value) =>
		_encrypter.encrypt(value, iv: _iv).base64;
	
	static String _decrypt(String value) =>
		_encrypter.decrypt64(value, iv: _iv);
	
	static Future<bool> create() async
	{
		var prefs = await SharedPreferences.getInstance();
		_school       = School(prefs.getString("school"));
		_savedCourses = prefs.getStringList("courses");
		_darkMode     = prefs.getString("theme") == "dark";
		_deviceSync   = prefs.getBool("device_sync");
		_googleSync   = prefs.getBool("google_sync");
		_username     = prefs.getString("username");
		_password     = prefs.getString("password");
		_lastLocation = prefs.getString("last_location");
		
		// Get unique ID before decrypting
		_uniqueId = await UniqueIdentifier.serial;
		
		// Password is encrypted, so requires decryption
		if (_password != null)
			_password = _decrypt(prefs.getString("password"));
		
		await CourseName.load();
		return true;
	}
}