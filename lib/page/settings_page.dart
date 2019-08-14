import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../preferences.dart';
import '../dialog/login_dialog.dart';
import '../dialog/privacy_policy_dialog.dart';
import '../dialog/license_dialog.dart';

class SettingsPage extends StatefulWidget
{
	@override
	State createState() => SettingsState();
}

class SettingsState extends State<SettingsPage>
{
	// For about card
	var _version = "v1.0.0";
	var _build = "1";
	
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
		// Children for both Android/iOS
		final children = <Widget>[
			_buildTitle(context, "General"),
			_buildButton("Change School", null, ()
			{
				Navigator.of(context).pop();
				Navigator.of(context).pushReplacementNamed("/start");
			}),
			SwitchListTile(
				title: Text("Dark Mode"),
				subtitle: Text("Use a dark theme for the app"),
				value: Preferences.darkMode,
				onChanged: (checked) =>
					setState(() => Preferences.darkMode = checked)
			),
			_buildButtonBar([])
		];
		
		// Add device sync if Android
		if (Platform.isAndroid)
		{
			children.insert(3, SwitchListTile(
				title: Text("Sync with device calendar"),
				subtitle: Text(
					"Automatically add course events to device calendar"
				),
				value: Preferences.deviceSync,
				onChanged: (checked)
				{
					// TODO
				}
			));
		}
		
		return _buildCard(children);
	}
	
	/// Card for account settings
	_buildAccountCard(BuildContext context)
	{
		return _buildCard([
			_buildTitle(context, "Account"),
			_buildButton(Preferences.accountId == null
				? "Not logged in" : "Logged in",
				Preferences.accountId == null
					? "You're currently not logged in to your school account"
					: "You're logged in", null
			),
			_buildButton(Preferences.accountId == null ? "Log in" : "Log out",
				null, () => Preferences.accountId == null
					? _showLogin(context) : _logOut()),
			_buildButtonBar([])
		]);
	}
	
	Future<bool> signInGoogle() async
	{
		try
		{
			Preferences.googleSignIn = await GoogleSignIn().signIn();
		}
		catch (err)
		{
			_showDialog("Error", "Something unexpected happened");
			return false;
		}
		
		// Canceled by user
		if (Preferences.googleSignIn == null)
			return false;
		return true;
	}
	
	void signOutGoogle() async
	{
		await GoogleSignIn().signOut();
		Preferences.googleSignIn = null;
	}
	
	/// Card for Google settings
	_buildGoogleCard(BuildContext context)
	{
		return _buildCard([
			_buildTitle(context, "Google"),
			_buildButton(Preferences.googleSignIn == null ? "Not logged in" : "Logged in",
				Preferences.googleSignIn == null ? "You're currently not logged in to your Google account" : "Logged in as ${Preferences.googleSignIn.displayName}", null
			),
			_buildButton(Preferences.googleSignIn == null ? "Log in" : "Log out", null, () async
			{
				setState(()
				{
					if (Preferences.googleSignIn == null)
						signInGoogle();
					else
						signOutGoogle();
				});
			}),
			SwitchListTile(
				title: Text("Sync with Google calendar"),
				subtitle: Text(
					"Automatically add course events to Google calendar"),
				value: false,
				onChanged: (checked)
				{
					setState(()
					{
						// TODO: Toggle setting here
					});
				},
			),
			_buildButtonBar([])
		]);
	}
	
	_buildAboutCard()
	{
		PackageInfo.fromPlatform().then((info) {
			setState(()
			{
				_version = "Version ${info.version}";
				_build   = "Build ${info.buildNumber}";
			});
		});
		
		return _buildCard([
			_buildTitle(context, "About"),
			_buildButton(_version, _build, null),
			_buildButton("Privacy Policy", null, ()
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
	
	_showDialog(String title, String message)
	{
		showDialog(
			context: context,
			builder: (builder) {
				return AlertDialog(
					title: Text(title),
					content: Text(message),
					actions: <Widget>[
						FlatButton(
							child: Text("OK"),
							onPressed: () => Navigator.of(context).pop(),
						)
					],
				);
			}
		);
	}
	
	_logOut() =>
		setState(() => Preferences.accountId = null);
	
	_showLogin(context)
	{
		Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return LoginDialog();
			},
			fullscreenDialog: true
		));
		
		if (Preferences.accountId != null)
			setState(() {});
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
				children: [
					_buildGeneralCard(context),
					_buildAccountCard(context),
					_buildGoogleCard(context),
					_buildAboutCard()
				],
			),
		);
	}
}