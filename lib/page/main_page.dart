import 'package:flutter/material.dart';

import 'schedule_page.dart';
import 'booking_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget
{
	@override
	State createState() => MainState();
}

class MainState extends State<MainPage> with SingleTickerProviderStateMixin
{
	/// Widgets for all tabs
	final _tabPages = <Widget>[
		SchedulePage(),
		BookingPage(),
		//ExamPage(),
		SettingsPage()
	];
	
	/// All tabs
	final _navBarItems = <BottomNavigationBarItem>
	[
		BottomNavigationBarItem(
			icon: Icon(Icons.calendar_today),
			title: Text("Schedule")
		),
		BottomNavigationBarItem(
			icon: Icon(Icons.access_time),
			title: Text("Booking")
		),
		BottomNavigationBarItem(
			icon: Icon(Icons.settings),
			title: Text("Settings")
		)
	];
	
	/// Current tab displayed
	var _navBarIndex = 0;
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			body: _tabPages[_navBarIndex],
			bottomNavigationBar: BottomNavigationBar(
				items: _navBarItems,
				currentIndex: _navBarIndex,
				onTap: (index) => setState(() => _navBarIndex = index),
			)
		);
}


class ExamPage extends StatefulWidget
{
	@override
	State createState() => ExamState();
}

class ExamState extends State<ExamPage>
{
	@override
	Widget build(BuildContext context) =>
		Padding(
			padding: EdgeInsets.all(32.0),
			child: Text(
				"This feature is currently not available, "
				"contact me if you want to help me out!",
				textAlign: TextAlign.center,
			),
		);
}
