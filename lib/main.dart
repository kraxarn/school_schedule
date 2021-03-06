import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'page/main_page.dart';
import 'page/start_page.dart';
import 'tool/preferences.dart';

void main()
{
	WidgetsFlutterBinding.ensureInitialized();
	Preferences.create().then((result) {
		runApp(MyApp());
	});
}

class MyApp extends StatelessWidget
{
	/// Base light or dark theme
	ThemeData get _baseTheme =>
		(Preferences.darkMode ? ThemeData.dark() : ThemeData.light());
	
	@override
	Widget build(BuildContext context) =>
		MaterialApp(
			title: "School Schedule",
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
			},
			localizationsDelegates: [
				GlobalMaterialLocalizations.delegate,
				GlobalWidgetsLocalizations.delegate
			],
			supportedLocales: [
				const Locale("en"),
				const Locale("sv")
			],
		);
}