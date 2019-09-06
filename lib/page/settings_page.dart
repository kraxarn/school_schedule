import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../dialog/license_dialog.dart';
import '../dialog/login_dialog.dart';
import '../dialog/privacy_policy_dialog.dart';
import '../dialog/changelog_dialog.dart';
import '../tool/preferences.dart';

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
	
	final _languages = {
		"en": Preferences.localized("english"),
		"sv": Preferences.localized("swedish")
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
				showDialog(
					context: context,
					builder: (builder) =>
						AlertDialog(
							title: Text("Are you sure?"),
							content: Text(
								"Changing school removes your login and saved courses, are you sure you want to change school?"
							),
							actions: <Widget>[
								FlatButton(
									child: Text("NO"),
									onPressed: () => Navigator.of(context).pop()
								),
								FlatButton(
									child: Text("YES"),
									onPressed: ()
									{
										Navigator.of(context).pop();
										Navigator.of(context).pushReplacementNamed("/start");
									}
								)
							]
						)
				);
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
			ListTile(
				title: Text(Preferences.localized("language_title")),
				subtitle: Text(Preferences.localized("language_info")),
				trailing: DropdownButton<String>(
					value: Preferences.locale.locale.languageCode,
					items: _languages.entries.map((value) =>
						DropdownMenuItem(
							child: Text(value.value),
							value: value.key,
						)).toList(),
					onChanged: (value) =>
						setState(() => Preferences.locale = value)
				),
			),
			_buildButtonBar([])
		];
		
		return _buildCard(children);
	}
	
	/// Card for schedule settings
	Widget _buildScheduleCard() =>
		_buildCard([
			_buildTitle(context, "Schedule"),
			SwitchListTile(
				title: Text("Course colors"),
				subtitle: Text("Set different title colors depending on course"),
				value: Preferences.courseColors,
				onChanged: (checked) =>
					setState(() => Preferences.courseColors = checked)
			),
			SwitchListTile(
				title: Text("Week numbers"),
				subtitle: Text("Show week numbers"),
				value: Preferences.showWeek,
				onChanged: (checked) =>
					setState(() => Preferences.showWeek = checked)
			),
			SwitchListTile(
				title: Text("Highlight collisions"),
				subtitle: Text(
					"Color time when multiple events occur at the same time"
				),
				value: Preferences.showEventCollision,
				onChanged: (checked) =>
					setState(() => Preferences.showEventCollision = checked)
			),
			SwitchListTile(
				title: Text("Today view"),
				subtitle: Text(
					"Display a subtitle with events for today"
				),
				value: Preferences.scheduleToday,
				onChanged: (checked) =>
					setState(() => Preferences.scheduleToday = checked)
			),
			_buildButtonBar([])
		]);
	
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
					_build   = "Build ${info.buildNumber}";
				}));
		}
		
		return _buildCard([
			_buildTitle(context, "About"),
			_buildButton(_version, _build, () => _showChangelog()),
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
		if (Preferences.school.id == null)
			return;
		
		Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return LoginDialog();
			},
			fullscreenDialog: true
		));
		
		if (Preferences.username != null)
			setState(() {});
	}
	
	void _showChangelog()
	{
		Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return ChangelogDialog();
			},
			fullscreenDialog: true
		));
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
					_buildScheduleCard(),
					_buildAccountCard(),
					_buildAboutCard()
				],
			),
		);
}