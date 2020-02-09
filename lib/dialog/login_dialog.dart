import 'dart:io';

import 'package:flutter/material.dart';

import '../tool/account.dart';
import '../tool/preferences.dart';

class LoginDialog extends StatefulWidget
{
	@override
	State createState() => LoginDialogState();
}

class LoginDialogState extends State<LoginDialog>
{
	/// Key used to verify input
	final _formKey = GlobalKey<FormState>();
	
	/// Username controller to get text in code
	final _usernameController = TextEditingController();
	
	/// Password controller to get text in code
	final _passwordController = TextEditingController();
	
	/// State of current school account login
	var _loggingIn = false;
	
	// We use a Dart HttpClient here because cookies
	final _http = HttpClient();
	
	/// Create a text field for a form
	Widget _buildTextField(String label, bool obscureText, bool autoFocus,
		TextEditingController controller, String Function(String) validator) =>
		TextFormField(
			autofocus: autoFocus,
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
	
	/// Show dialog when login fails
	void _showResultDialog(String content)
	{
		showDialog(
			context: context,
			builder: (builder) =>
				AlertDialog(
					title: Text(Preferences.localized("login_failed")),
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
	
	/// Attempt login
	void _login() async
	{
		// Show that we're logging in
		setState(() => _loggingIn = true);
		
		// Try to login
		final account = await Account.login(_http,
			_usernameController.text, _passwordController.text);
		account?.save();
		
		setState(() => _loggingIn = false);
		
		if (account == null)
			_showResultDialog(Preferences.localized("incorrect_login"));
		else
			Navigator.of(context).pop();
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text(Preferences.localized("title_login")),
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
								top:    32.0,
								left:   32.0,
								right:  32.0,
								bottom: 16.0
							),
							child: _buildTextField(
								Preferences.localized("username"), false, true,
								_usernameController, (value) =>
								value.isEmpty
									? Preferences.localized("enter_username")
									: null),
						),
						Padding(
							padding: EdgeInsets.only(
								left:   32.0,
								right:  32.0,
								bottom: 16.0
							),
							child: _buildTextField(
								Preferences.localized("password"), true, false,
								_passwordController, (value) =>
								value.isEmpty
									? Preferences.localized("enter_password")
									: null)
						),
						ButtonTheme.bar(
							child: ButtonBar(
								children: <Widget>[
									Padding(
										padding: EdgeInsets.symmetric(
											horizontal: 32.0
										),
										child: FlatButton(
											child: Text(
												Preferences.localized("login")
											),
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