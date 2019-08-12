import 'dart:io';

import 'package:flutter/material.dart';

import '../account.dart';

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