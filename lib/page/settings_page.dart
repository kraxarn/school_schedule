import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../dialog/license_dialog.dart';
import '../dialog/login_dialog.dart';
import '../dialog/privacy_policy_dialog.dart';
import '../preferences.dart';

class SettingsPage extends StatefulWidget
{
	@override
	State createState() => SettingsState();
}

class SettingsState extends State<SettingsPage>
{
	/// Scaffold state for showing snack bars
	final _scaffoldKey = GlobalKey<ScaffoldState>();
	
	// For about card
	var _version = "version";
	var _build   = "build";
	
	/// Allowed refresh intervals as <minutes, formatted>
	final _refreshIntervals = {
		0:   "Disabled",
		15:  "15 minutes",
		60:  "1 hour",
		240: "4 hours"
	};
	
	/// Build a card with children in a column
	Widget _buildCard(List<Widget> children) =>
		Card(
			child: Column(
				children: children
			),
		);
	
	/// Build title with larger text
	Widget _buildTitle(BuildContext context, String title) =>
		ListTile(
			title: Text(
				title,
				style: Theme.of(context).textTheme.title,
			)
		);
	
	/// Build a button with optional subtitle
	Widget _buildButton(String title, String subtitle, void Function() onTap) =>
		ListTile(
			title: Text(title),
			subtitle: subtitle == null ? null : Text(subtitle),
			onTap: onTap,
		);
	
	/// Build a button bar (or use as padding)
	Widget _buildButtonBar(List<Widget> children) =>
		ButtonTheme.bar(
			child: ButtonBar(
				children: children
			)
		);
	
	/// Card for general settings
	Widget _buildGeneralCard()
	{
		// Children for both Android/iOS
		final children = <Widget>[
			_buildTitle(context, "General"),
			_buildButton("Change school", "Currently ${Preferences.school.name}", ()
			{
				Navigator.of(context).pop();
				Navigator.of(context).pushReplacementNamed("/start");
			}),
			SwitchListTile(
				title: Text("Dark theme"),
				subtitle: Text("Use a dark theme for the app"),
				value: Preferences.darkMode,
				onChanged: (checked)
				{
					_scaffoldKey.currentState.showSnackBar(SnackBar(
						content: Text("Restart app to apply changes"),
						duration: Duration(
							seconds: 2
						)
					));
					setState(() => Preferences.darkMode = checked);
				}
			),
			SwitchListTile(
				title: Text("Course colors"),
				subtitle: Text("Set different title colors depending on course in schedule"),
				value: Preferences.courseColors,
				onChanged: (checked)
				{
					setState(() => Preferences.courseColors = checked);
				}
			),
			_buildButtonBar([])
		];
		
		// Add device sync and refresh interval if Android
		// Until implemented, debug only
		if (!kReleaseMode && Platform.isAndroid)
		{
			children.insertAll(4, [
				SwitchListTile(
					title: Text("Sync with device calendar"),
					subtitle: Text(
						"Automatically add course events to device calendar"
					),
					value: Preferences.deviceSync,
					onChanged: (checked)
					{
						// TODO
					}
				),
				ListTile(
					title: Text("Refresh interval"),
					subtitle: Text(
						"How often to refresh the schedule in the background"
					),
					trailing: DropdownButton<String>(
						value: _refreshIntervals[Preferences.refreshInterval],
						onChanged: (value) =>
							setState(() => Preferences.refreshInterval =
								_refreshIntervals.entries
									.firstWhere((entry) =>
									entry.value == value).key
							),
						items: _refreshIntervals.values
							.map<DropdownMenuItem<String>>((value) =>
							DropdownMenuItem(
								child: Text(value),
								value: value
							)
						).toList()
					)
				)
			]);
		}
		
		return _buildCard(children);
	}
	
	/// Card for account settings
	Widget _buildAccountCard()
	{
		return _buildCard([
			_buildTitle(context, "Account"),
			_buildButton(Preferences.username == null
				? "Not logged in" : "Logged in",
				Preferences.username == null
					? "You're currently not logged in to your school account"
					: "You're logged in as ${Preferences.username}", null
			),
			_buildButton(Preferences.username == null ? "Log in" : "Log out",
				null, () => Preferences.username == null
					? _showLogin(context) : _logOut()),
			_buildButtonBar([])
		]);
	}
	
	/// Card for about section
	Widget _buildAboutCard()
	{
		if (_version == "version" || _build == "build")
		{
			PackageInfo.fromPlatform().then((info) =>
				setState(()
				{
					_version = "Version ${info.version}";
					_build = "Build ${info.buildNumber}";
				}));
		}
		
		return _buildCard([
			_buildTitle(context, "About"),
			_buildButton(_version, _build, null),
			_buildButton("Privacy policy", null, ()
			{
				Navigator.of(context).push(MaterialPageRoute(
					builder: (builder) {
						return PrivacyPolicyDialog();
					},
					fullscreenDialog: true
				));
			}),
			_buildButton("Licenses", null, ()
			{
				Navigator.of(context).push(MaterialPageRoute(
					builder: (builder) {
						return LicenseDialog();
					},
					fullscreenDialog: true
				));
			}),
			_buildButtonBar([])
		]);
	}
	
	/// Log out (remove username and password)
	void _logOut() =>
		setState(() => Preferences.username = Preferences.password = null);
	
	/// Show login dialog
	void _showLogin(context)
	{
		Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return LoginDialog();
			},
			fullscreenDialog: true
		));
		
		if (Preferences.username != null)
			setState(() {});
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			key: _scaffoldKey,
			appBar: AppBar(
				title: Text("Settings"),
			),
			body: ListView(
				padding: EdgeInsets.all(16.0),
				children: [
					_buildGeneralCard(),
					_buildAccountCard(),
					_buildAboutCard()
				],
			),
		);
}