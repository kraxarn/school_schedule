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
	/// Base light or dark theme
	ThemeData get _baseTheme =>
		(Preferences.darkMode ? ThemeData.dark() : ThemeData.light());
	
	@override
	Widget build(BuildContext context) =>
		MaterialApp(
			title: "KronoX",
			theme: _baseTheme.copyWith(
				primaryColor:     Colors.blue[700],
				primaryColorDark: Colors.blue[900],
				accentColor:      Preferences.darkMode
					? Colors.indigoAccent[200] : Colors.indigoAccent[400]
			),
			home: Preferences.school == null ? StartPage() : MainPage(),
			routes: {
				"/start": (context) => StartPage(),
				"/main":  (context) => MainPage()
			}
		);
}