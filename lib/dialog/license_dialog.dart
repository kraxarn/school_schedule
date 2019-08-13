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
	
	@override
	void initState()
	{
		super.initState();
		
		final client = http.Client();
		
		// Dart SDK
		client.read("https://raw.githubusercontent.com/dart-lang/sdk/master/LICENSE").then((response)
		{
			_addLicense("Dart SDK", response);
			// Flutter SDK, shared_preferences and package_info
			client.read("https://raw.githubusercontent.com/flutter/flutter/master/LICENSE").then((response)
			{
				_addLicense("Flutter and Flutter plugins", response);
				// Dart HTTP
				client.read("https://raw.githubusercontent.com/dart-lang/http/master/LICENSE").then((response) {
					_addLicense("Dart plugins", response);
					// flutter_markdown
					client.read("https://raw.githubusercontent.com/flutter/flutter_markdown/master/LICENSE").then((response) {
						_addLicense("Flutter Markdown", response);
						// device_calendar
						client.read("https://raw.githubusercontent.com/builttoroam/flutter_plugins/master/device_calendar/LICENSE").then((response) {
							_addLicense("Device Calendar", response);
							setState(() => _loading = false);
						});
					});
				});
			});
		});
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