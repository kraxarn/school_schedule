
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// TODO: Using markdown is a lacy way to get HTML rendered properly
import 'package:flutter_markdown/flutter_markdown.dart';

class SettingsPage extends StatefulWidget
{
	@override
	State createState() =>
		SettingsState();
}

class SettingsState extends State<SettingsPage>
{
	// Temporary
	var _darkMode  = false;
	var _deviceCal = false;
	var _googleCal = false;
	
	_buildCard(List<Widget> children) =>
		Card(
			child: Column(
				children: children
			),
		);
	
	_buildTitle(BuildContext context, String title) =>
		ListTile(
			title: Text(
				title,
				style: Theme.of(context).textTheme.title,
			)
		);
	
	_buildButton(String title, String subtitle, void Function() onTap) =>
		ListTile(
			title: Text(title),
			subtitle: subtitle == null ? null : Text(subtitle),
			onTap: onTap,
		);
	
	_buildButtonBar(List<Widget> children) =>
		ButtonTheme.bar(
			child: ButtonBar(
				children: children
			)
		);
	
	/// Card for general settings
	_buildGeneralCard(BuildContext context)
	{
		return _buildCard([
			_buildTitle(context, "General"),
			_buildButton("Change School", null, ()
			{
				Navigator.of(context).pop();
				Navigator.of(context).pushReplacementNamed("/start");
			}),
			_buildButton("Privacy Policy", null, ()
			{
				Navigator.of(context).push(MaterialPageRoute(
					builder: (builder) {
						return PrivacyPolicyDialog();
					},
					fullscreenDialog: true
				));
			}),
			SwitchListTile(
				title: Text("Dark Mode"),
				subtitle: Text("Use a dark theme for the app"),
				value: _darkMode,
				onChanged: (checked)
				{
					setState(()
					{
						_darkMode = checked;
					});
				}
			),
			SwitchListTile(
				title: Text("Sync with device calendar"),
				subtitle: Text(
					"Automatically add course events to device calendar"
				),
				value: _deviceCal,
				onChanged: (checked)
				{
					setState(()
					{
						_deviceCal = checked;
					});
				}
			),
			_buildButtonBar([])
		]);
	}
	
	/// Card for account settings
	_buildAccountCard(BuildContext context)
	{
		return _buildCard([
			_buildTitle(context, "Account"),
			_buildButton("Not logged in",
				"You're currently not logged in to your school account", null
			),
			_buildButton("Log in", null, () {
			}),
			_buildButtonBar([])
		]);
	}
	
	/// Card for Google settings
	_buildGoogleCard(BuildContext context)
	{
		return _buildCard([
			_buildTitle(context, "Google"),
			_buildButton("Not logged in",
				"You're currently not logged in to your Google account", null
			),
			_buildButton("Log in", null, () {
			}),
			SwitchListTile(
				title: Text("Sync with Google calendar"),
				subtitle: Text(
					"Automatically add course events to Google calendar"),
				value: _googleCal,
				onChanged: (checked)
				{
					setState(()
					{
						_googleCal = checked;
					});
				},
			),
			_buildButtonBar([])
		]);
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			appBar: AppBar(
				title: Text("Settings"),
			),
			body: ListView(
				padding: EdgeInsets.all(16.0),
				children: <Widget>[
					_buildGeneralCard(context),
					_buildAccountCard(context),
					_buildGoogleCard(context)
				],
			),
		);
	}
}

class PrivacyPolicyDialog extends StatefulWidget
{
	@override
	State createState() =>
		PrivacyPolicyState();
}

class PrivacyPolicyState extends State<PrivacyPolicyDialog>
{
	var _loading = true;
	
	var _privacyPolicy = "";
	
	@override
	Widget build(BuildContext context)
	{
		http.read("https://kronox.se/app/privacypolicy.php").then((response) {
			setState(() {
				_privacyPolicy = response.substring(
					response.indexOf("</head>") + 7,
					response.indexOf("</html>")
				).replaceAll("<h2>", "## ").replaceAll("</h2>", "").trim();
				_loading = false;
			});
		});
		
		return Scaffold(
			appBar: AppBar(
				title: Text("Privacy Policy"),
			),
			body: Padding(
				padding: EdgeInsets.all(0.0),
				child: _loading ? Align(
					alignment: Alignment.topCenter,
					child: CircularProgressIndicator(),
				) : Scrollbar(
					child: Markdown(
						data: _privacyPolicy
					),
				)
			),
		);
	}
}