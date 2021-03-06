import 'dart:convert';
import 'dart:io';

import 'preferences.dart';

/// Stuff related to school account
class Account
{
	String _username, _password;
	
	Account([this._username, this._password]);
	
	/// Saves account id to settings
	void save()
	{
		Preferences.username = _username;
		Preferences.password = _password;
	}
	
	/// Create a new session
	static Future<Cookie> getSession(HttpClient httpClient) async
	{
		// Get session cookie
		// (/hjalp.jsp seems to be lightest page to load)
		final sessionResponse = await (await httpClient.getUrl(Uri.parse(
			"${Preferences.school.baseUrl}/hjalp.jsp"))).close();
	
		// Get cookie from first response
		final cookies = sessionResponse.cookies;
		if (cookies.length != 1)
			print("cookies length not exepcted value (${cookies.length})");
		
		// There should only be one cookie,
		// but in case it isn't, we find the correct one
		return cookies.firstWhere((cookie) => cookie.name == "JSESSIONID");
	}
	
	static Future<Account> login(HttpClient httpClient, String username, String password) async
	{
		// Try logging in
		final request = await httpClient.getUrl(Uri.parse(
			"${Preferences.school.baseUrl}/ajax/"
				"ajax_login.jsp?username=$username&password=$password"));
		
		request.cookies.add(await Preferences.sessionCookie);
		final response = await request.close();
		final body = await response.transform(utf8.decoder).join();
		
		if (body.trim() == "OK")
			return Account(username, password);
		
		print("login failed: $body");
		return null;
	}
}