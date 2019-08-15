import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class LicenseDialog extends StatefulWidget
{
	@override
	State createState() => LicenseState();
}

class LicenseState extends State<LicenseDialog>
{
	// This is very similar to the privacy policy view
	
	var _loading = true;
	
	var _licenses = "";
	
	_addLicense(String title, String message) =>
		_licenses += "\n# $title\n\n$message";
	
	void _loadLicenses() async
	{
		final client = http.Client();
		
		// Dart SDK
		_addLicense("Dart SDK", await client.read(
			"https://raw.githubusercontent.com/dart-lang/sdk/master/LICENSE"));
		// Flutter SDK, shared_preferences and package_info
		_addLicense("Flutter and Flutter plugins", await client.read(
			"https://raw.githubusercontent.com/flutter/flutter/master/LICENSE"));
		// Dart HTTP and HTML
		_addLicense("Dart plugins", await client.read(
			"https://raw.githubusercontent.com/dart-lang/http/master/LICENSE"));
		// flutter_markdown
		_addLicense("Flutter Markdown", await client.read(
			"https://raw.githubusercontent.com/flutter/flutter_markdown/master/LICENSE"));
		
		setState(() => _loading = false);
	}
	
	@override
	void initState()
	{
		super.initState();
		_loadLicenses();
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			appBar: AppBar(
				title: Text("Licenses"),
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
}