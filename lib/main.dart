import 'package:flutter/material.dart';

import 'page/start_page.dart';
import 'page/main_page.dart';
import 'page/settings_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget
{
	@override
	Widget build(BuildContext context)
	{
		return MaterialApp(
			title: "KronoX",
			theme: ThemeData.dark().copyWith(
				primaryColor: Colors.orange[500],
				primaryColorDark: Colors.orange[700],
				accentColor: Colors.deepOrangeAccent
			),
			home: StartPage(),
			routes: {
				"/start":    (context) => StartPage(),
				"/main":     (context) => MainPage(),
				"/settings": (context) => SettingsPage()
			},
		);
	}
}