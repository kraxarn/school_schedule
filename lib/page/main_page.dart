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
							Navigator.of(context).pushNamed("/settings");
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
