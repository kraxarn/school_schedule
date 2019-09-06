import 'package:flutter/material.dart';

import 'schedule_page.dart';
import 'booking_page.dart';
import 'settings_page.dart';
import '../tool/preferences.dart';

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
			title: Text(Preferences.localized("title_schedule"))
		),
		BottomNavigationBarItem(
			icon: Icon(Icons.access_time),
			title: Text(Preferences.localized("title_booking"))
		),
		BottomNavigationBarItem(
			icon: Icon(Icons.settings),
			title: Text(Preferences.localized("title_settings"))
		)
	];
	
	/// Current tab displayed
	/// (static so we can access it from the other pages easily)
	/// (should never have more than one instance anyway)
	static var navBarIndex = 0;
	
	@override
	Widget build(BuildContext context)
	{
		Preferences.buildContext = context;
		
		return Scaffold(
			body: _tabPages[navBarIndex],
			bottomNavigationBar: BottomNavigationBar(
				items: _navBarItems,
				currentIndex: navBarIndex,
				onTap: (index) => setState(() => navBarIndex = index),
			)
		);
	}
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
