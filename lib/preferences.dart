import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

import 'account.dart';
import 'course_name.dart';

/// Application preferences
class Preferences
{
	/// Shortcut for SharedPreference.getInstance()
	static Future<SharedPreferences> get _prefs =>
		SharedPreferences.getInstance();
	
	static String _uniqueId;
	
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
	
	/// How often to refresh in the background
	static int _refreshInterval;
	static int get refreshInterval => _refreshInterval ?? 60;
	static set refreshInterval(int value)
	{
		_refreshInterval = value;
		_prefs.then((prefs) => prefs.setInt("refresh_interval", value));
	}
	
	/// School login ID
	static String _accountId;
	static String get accountId => _accountId;
	static set accountId(String value)
	{
		_accountId = value;
		_prefs.then((prefs) => prefs.setString("account", value));
	}
	
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
		_school       = prefs.getString("school");
		_savedCourses = prefs.getStringList("courses");
		_darkMode     = prefs.getString("theme") == "dark";
		_deviceSync   = prefs.getBool("device_sync");
		_accountId    = prefs.getString("account");
		_googleSync   = prefs.getBool("google_sync");
		_username     = prefs.getString("username");
		_password     = prefs.getString("password");
		
		// Get unique ID before decrypting
		_uniqueId = await UniqueIdentifier.serial;
		
		// Password is encrypted, so requires decryption
		if (_password != null)
		{
			_password = _decrypt(prefs.getString("password"));
			
			// Refresh login
			// This might take a little while, so we don't wait for it
			Account.login(HttpClient(), _username, _password,
				Cookie("JSESSIONID", _accountId));
		}
		
		await CourseName.load();
		return true;
	}
}