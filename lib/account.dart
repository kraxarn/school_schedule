import 'dart:convert';
import 'dart:io';

import 'preferences.dart';

/// Stuff related to school account
class Account
{
	String _username, _password;
	
	Cookie _session;
	
	Account(this._session, [this._username, this._password]);
	
	/// Saves account id to settings
	void save()
	{
		Preferences.accountId = _session.value;
		Preferences.username  = _username;
		Preferences.password  = _password;
	}
	
	/// Create a new session
	static Future<Cookie> getSession(HttpClient httpClient) async
	{
		// Get session cookie
		final sessionResponse = await (await httpClient.getUrl(Uri.parse(
			"https://webbschema.${Preferences.school}.se"))).close();
	
		// Get cookie from first response
		final cookies = sessionResponse.cookies;
		if (cookies.length != 1)
			print("cookies length not exepcted value (${cookies.length})");
		
		// There should only be one cookie,
		// but in case it isn't, we find the correct one
		return cookies.firstWhere((cookie) => cookie.name == "JSESSIONID");
	}
	
	static Future<Account> login(HttpClient httpClient, String username, String password, Cookie session) async
	{
		// Check if no session
		if (session == null)
			session = await getSession(httpClient);
		
		// Then try logging in
		final request = await httpClient.getUrl(Uri.parse(
			"https://webbschema.${Preferences.school}.se/ajax/"
				"ajax_login.jsp?username=$username&password=$password"));
		
		request.cookies.add(session);
		final response = await request.close();
		final body = await response.transform(utf8.decoder).join();
		
		if (body.trim() == "OK")
			return Account(session, username, password);
		return null;
	}
}