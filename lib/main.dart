import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'page/main_page.dart';
import 'page/start_page.dart';

void main()
{
	SharedPreferences.getInstance().then((prefs) {
		runApp(MyApp(
			prefs.getString("theme") == "dark"
				? ThemeData.dark() : ThemeData.light()
		));
	});
}

class MyApp extends StatelessWidget
{
	final ThemeData _baseTheme;
	
	MyApp(this._baseTheme);
	
	@override
	Widget build(BuildContext context)
	{
		return MaterialApp(
			title: "KronoX",
			theme: _baseTheme.copyWith(
				primaryColor: Colors.orange[500],
				primaryColorDark: Colors.orange[700],
				accentColor: Colors.deepOrangeAccent
			),
			home: StartPage(),
			routes: {
				"/start":    (context) => StartPage(),
				"/main":     (context) => MainPage()
			},
		);
	}
}