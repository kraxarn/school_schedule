import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import '../tool/preferences.dart';

class LicenseDialog extends StatefulWidget
{
	@override
	State createState() => LicenseState();
}

class LicenseState extends State<LicenseDialog>
{
	// This is very similar to the privacy policy view
	
	/// If we're fetching licenses
	var _loading = true;
	
	/// Temporary string to save to later
	var _licenses = "";
	
	/// Format license with a title and add to string
	void _addLicense(String title, String message) =>
		_licenses += "\n# $title\n\n$message";
	
	/// Fetch all licenses
	void _loadLicenses() async
	{
		final client = http.Client();

		final dartSdk = Uri.parse("https://raw.githubusercontent.com/dart-lang/sdk/master/LICENSE");
		final flutterSdk = Uri.parse("https://raw.githubusercontent.com/flutter/flutter/master/LICENSE");
		final dartHttpHtml = Uri.parse("https://raw.githubusercontent.com/dart-lang/http/master/LICENSE");
		final flutterMarkdown = Uri.parse("https://raw.githubusercontent.com/flutter/flutter_markdown/master/LICENSE");
		final encrypt = Uri.parse("https://raw.githubusercontent.com/leocavalcante/encrypt/master/LICENSE");

		// Dart SDK
		_addLicense("Dart SDK", await client.read(dartSdk));
		// Flutter SDK, shared_preferences and package_info
		_addLicense("Flutter and Flutter plugins", await client.read(flutterSdk));
		// Dart HTTP and HTML
		_addLicense("Dart plugins", await client.read(dartHttpHtml));
		// flutter_markdown
		_addLicense("Flutter Markdown", await client.read(flutterMarkdown));
		// encrypt
		_addLicense("encrypt", await client.read(encrypt));
		
		setState(() => _loading = false);
	}
	
	@override
	void initState()
	{
		super.initState();
		_loadLicenses();
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text(Preferences.localized("licenses")),
			),
			body: _loading ? Center(
				child: CircularProgressIndicator()
			) : Scrollbar(
				child: Markdown(
					data: _licenses
				),
			)
		);
}