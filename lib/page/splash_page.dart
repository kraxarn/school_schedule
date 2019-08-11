
import 'package:flutter/material.dart';

import '../preferences.dart';

class SplashPage extends StatelessWidget
{
	@override
	Widget build(BuildContext context)
	{
		Preferences.create().then((result) {
			Navigator.of(context).pushReplacementNamed(
				Preferences.school == null ? "/start" : "/main"
			);
		});
		
		return Scaffold(
			backgroundColor: Color.fromARGB(255, 25, 118, 210)
		);
	}
}