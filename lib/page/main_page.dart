import 'package:flutter/material.dart';
import 'package:school_schedule/page/settings_page.dart';

import 'schedule_page.dart';
import 'booking_page.dart';

class MainPage extends StatefulWidget
{
	@override
	State createState() =>
		MainState();
}

class MainState extends State<MainPage> with SingleTickerProviderStateMixin
{
	final _tabPages = <Widget>[
		SchedulePage(),
		BookingPage(),
		//ExamPage()
	];
	
	final _tabItems = <Tab>[
		Tab(
			child: ListTile(
				leading: Icon(Icons.calendar_today),
				title: Text("Schedule"),
			),
		),
		Tab(
			child: ListTile(
				leading: Icon(Icons.access_time),
				title: Text("Booking"),
			),
		)
	];
	
	TabController _tabController;
	
	@override
	void initState()
	{
		super.initState();
		_tabController = TabController(
			vsync: this,
			length: _tabItems.length
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
						icon: Icon(Icons.settings),
						onPressed: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (context) => SettingsPage()
								)
							);
						},
					)
				],
				bottom: TabBar(
					tabs: _tabItems,
					controller: _tabController,
				),
			),
			body: TabBarView(
				controller: _tabController,
				children: _tabPages,
			)
		);
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
		return Padding(
			padding: EdgeInsets.all(32.0),
			child: Text(
				"This feature is currently not available, "
				"contact me if you want to help me out!",
				textAlign: TextAlign.center,
			),
		);
	}
}
