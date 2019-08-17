import 'package:flutter/material.dart';

import 'page/main_page.dart';
import 'page/start_page.dart';
import 'preferences.dart';

void main() =>
	Preferences.create().then((result) {
		runApp(MyApp());
	});

class MyApp extends StatelessWidget
{
	ThemeData get _baseTheme =>
		(Preferences.darkMode ? ThemeData.dark() : ThemeData.light());
	
	@override
	Widget build(BuildContext context)
	{
		return MaterialApp(
			title: "KronoX",
			theme: _baseTheme.copyWith(
				primaryColor: Colors.blue[500],
				primaryColorDark: Colors.blue[700],
				accentColor: Colors.blueAccent
			),
			home: Preferences.school == null ? StartPage() : MainPage(),
			routes: {
				"/start": (context) => StartPage(),
				"/main":  (context) => MainPage()
			}
		);
	}
}