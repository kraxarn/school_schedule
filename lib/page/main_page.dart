import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'schedule_page.dart';

class MainPage extends StatefulWidget
{
	@override
	State createState() =>
		MainState();
}

class MainState extends State<MainPage>
{
	var _tabIndex = 0;
	
	final _tabPages = <Widget>[
		SchedulePage(),
		BookPage(),
		ExamPage()
	];
	
	final _navigationBarItems = <BottomNavigationBarItem>[
		BottomNavigationBarItem(
			title: Text("Schedule"),
			icon: Icon(Icons.calendar_today)
		),
		BottomNavigationBarItem(
			title: Text("Booking"),
			icon: Icon(Icons.access_time)
		),
		BottomNavigationBarItem(
			title: Text("Exams"),
			icon: Icon(Icons.school)
		)
	];
	
	// TODO: This is just temporary until we have proper settings
	_showSettings(context)
	{
		showDialog(
			context: context,
			builder: (builder) {
				return SimpleDialog(
					title: Text("Settings"),
					children: <Widget>[
						ListTile(
							leading: Icon(Icons.school),
							title: Text("Change School"),
							onTap: () {
								Navigator.of(context).pop();
								Navigator.of(context).pushReplacementNamed("/start");
							},
						),
						ListTile(
							leading: Icon(Icons.text_fields),
							title: Text("Privacy Policy"),
							onTap: () {
								Navigator.of(context).pop();
							},
						)
					],
				);
			}
		);
	}
	
	_createTextField(String label, bool obscureText)
	{
		return TextField(
			obscureText: obscureText,
			decoration: InputDecoration(
				labelText: label,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.all(
						Radius.circular(8.0)
					)
				)
			),
		);
	}
	
	_showLogin(context)
	{
		showDialog(
			context: context,
			builder: (builder) {
				return SimpleDialog(
					title: Text("Login"),
					children: <Widget>[
						Padding(
							padding: EdgeInsets.all(16.0),
							child: _createTextField("Username", false),
						),
						Padding(
							padding: EdgeInsets.only(
								left: 16.0,
								right: 16.0,
								bottom: 16.0
							),
							child: _createTextField("Password", true),
						),
						ButtonTheme.bar(
							child: ButtonBar(
								children: <Widget>[
									FlatButton(
										child: Text("CANCEL"),
										onPressed: () {
											Navigator.of(context).pop();
										},
									),
									FlatButton(
										child: Text("OK"),
										onPressed: () {
											Navigator.of(context).pop();
										},
									)
								],
							),
						)
					],
				);
			}
		);
	}
	
	@override
	Widget build(BuildContext context)
	{
		return Scaffold(
			appBar: AppBar(
				title: Text("KronoX"),
				actions: <Widget>[
					IconButton(
						icon: Icon(Icons.account_circle),
						onPressed: () {
							_showLogin(context);
						}
					),
					IconButton(
						icon: Icon(Icons.settings),
						onPressed: () {
							_showSettings(context);
						},
					)
				],
			),
			bottomNavigationBar: BottomNavigationBar(
				items: _navigationBarItems,
				currentIndex: _tabIndex,
				onTap: (index) {
					setState(() {
						_tabIndex = index;
					});
				},
			),
			body: _tabPages[_tabIndex]
		);
	}
}

class BookPage extends StatefulWidget
{
	@override
	State createState() =>
		BookState();
}

class BookState extends State<BookPage>
{
	@override
	Widget build(BuildContext context)
	{
		return Text("BookPage");
	}
}

class ExamPage extends StatefulWidget
{
	@override
	State createState() =>
		ExamState();
}

class ExamState extends State<ExamPage>
{
	@override
	Widget build(BuildContext context)
	{
		return Text("ExamPage");
	}
}
