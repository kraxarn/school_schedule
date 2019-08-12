import 'dart:convert';
import 'dart:io';

import 'preferences.dart';

/// Stuff related to school account
class Account
{
	Cookie _session;
	
	Account(this._session);
	
	/// Attempts login
	/// Returns Account on success or null on failure
	/// TODO: This uses the http package
	///  which currently does not support cookies until #20 is fixed
	/*static Future<Account> login(String username, String password) async
	{
		// HTTP client to use throughout the method
		final client = http.Client();
		
		// Get response from home page
		final response = await client.get(
			"https://webbschema.${Preferences.school}.se");
		
		// Get the cookies and check if we got a session cookie
		final headers = response.headers;
		final cookies = response.headers["set-cookie"];
		if (!cookies.contains("JSESSIONID"))
			return null;
		print("login_cookies: $cookies");
		
		// Extract the session cookie from the cookies string
		final session = cookies.substring(
			cookies.indexOf('=') + 1, cookies.indexOf(';'));
		print("login_session: $session");
		
		// Try logging in
		final loginResponse = await http.read(
			"https://webbschema.${Preferences.school}.se/ajax/"
				"ajax_login.jsp?username=$username&password=$password",
			headers: headers
		);
		
		print("login_response: $loginResponse");
		
		if (loginResponse != "OK")
			return null;
		return Account(session);
	}*/
	
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
			return Account(session);
		return null;
	}
}