import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

import '../account.dart';
import '../preferences.dart';

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
		return _buildCard([
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
			SwitchListTile(
				title: Text("Sync with device calendar"),
				subtitle: Text(
					"Automatically add course events to device calendar"
				),
				value: false,
				onChanged: (checked)
				{
					// TODO: Toggle setting here
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

enum LoginState
{
	notLoggingIn,
	loggingIn,
	loginError
}

class LoginDialog extends StatefulWidget
{
	@override
	State createState() => LoginDialogState();
}

class LoginDialogState extends State<LoginDialog>
{
	final _formKey = GlobalKey<FormState>();
	
	final _usernameController = TextEditingController();
	final _passwordController = TextEditingController();
	
	/// State of current school account login
	var _loggingIn = false;
	
	// We use a Dart HttpClient here because cookies
	final _http = HttpClient();
	Cookie _session;
	
	_buildTextField(String label, bool obscureText,
		TextEditingController controller, String Function(String) validator)
	{
		return TextFormField(
			controller: controller,
			obscureText: obscureText,
			decoration: InputDecoration(
				labelText: label,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.all(
						Radius.circular(8.0)
					)
				)
			),
			validator: validator,
		);
	}
	
	_showResultDialog(String content)
	{
		showDialog(
			context: context,
			builder: (builder) =>
				AlertDialog(
					title: Text("Login Failed"),
					content: Text(content),
					actions: <Widget>[
						FlatButton(
							child: Text("OK"),
							onPressed: () => Navigator.of(context).pop(),
						)
					],
				)
			
		);
	}
	
	void _login() async
	{
		// Show that we're logging in
		setState(() => _loggingIn = true);
		
		// If no session known, create
		if (_session == null)
			_session = await Account.getSession(_http);
		
		// Try to login
		final account = await Account.login(_http,
			_usernameController.text, _passwordController.text, _session);
		account?.save();
		
		setState(() => _loggingIn = false);
		
		if (account == null)
			_showResultDialog("Incorrect username or password");
		else
			Navigator.of(context).pop();
	}
	
	@override
	Widget build(BuildContext context)
	{
		// Return a basic view
		return Scaffold(
			appBar: AppBar(
				title: Text("School Login"),
			),
			body: Form(
				key: _formKey,
				child: Column(
					children: <Widget>[
						_loggingIn ? LinearProgressIndicator(
							backgroundColor: Color.fromARGB(0, 0, 0, 0),
						) : SizedBox(),
						Padding(
							padding: EdgeInsets.only(
								top: 32.0,
								left: 32.0,
								right: 32.0,
								bottom: 16.0
							),
							child: _buildTextField("Username", false,
								_usernameController, (value) =>
									value.isEmpty
										? "Please enter username" : null),
						),
						Padding(
							padding: EdgeInsets.only(
								left: 32.0,
								right: 32.0,
								bottom: 16.0
							),
							child: _buildTextField("Password", true,
								_passwordController, (value) =>
									value.isEmpty
										? "Please enter password" : null)
						),
						ButtonTheme.bar(
							child: ButtonBar(
								children: <Widget>[
									Padding(
										padding: EdgeInsets.symmetric(
											horizontal: 32.0
										),
										child: FlatButton(
											child: Text("LOGIN"),
											onPressed: ()
											{
												if (_formKey.currentState
													.validate())
													_login();
											}
										),
									),
								]
							)
						)
					],
				)
			)
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
	/// If we're currently loading the privacy policy
	var _loading = true;
	
	/// String the privacy policy will be written to later
	var _privacyPolicy = "";
	
	@override
	void initState()
	{
		super.initState();
		
		// We start fetching it ahead of time
		http.read("https://kronox.se/app/privacypolicy.php").then((response) {
			setState(() {
				_privacyPolicy = response.substring(
					response.indexOf("</head>") + 7,
					response.indexOf("</html>")
				).replaceAll("<h2>", "## ").replaceAll("</h2>", "").trim();
				_loading = false;
			});
		});
	}
	
	@override
	Widget build(BuildContext context)
	{
		// Return a basic view
		return Scaffold(
			appBar: AppBar(
				title: Text("Privacy Policy"),
			),
			// Show centered progress indicator while loading
			body: _loading ? Center(
				child: CircularProgressIndicator()
			) : Scrollbar(
				child: Markdown(
					data: _privacyPolicy
				),
			)
		);
	}
}

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
						setState(() => _loading = false);
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