import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import '../tool/preferences.dart';

class BookingHelpDialog extends StatefulWidget
{
	@override
	State createState() => BookingHelpDialogState();
}

class BookingHelpDialogState extends State<BookingHelpDialog>
{
	var _loading = true;
	
	var _content = "";
	
	void _loadContent() async
	{
		_content = await http.read(
			"https://raw.githubusercontent.com/kraxarn/school_schedule/master"
				"/img/booking_help/${Preferences.locale.locale.languageCode}.md"
		);
		setState(() =>_loading = false);
	}
	
	@override
	void initState()
	{
		super.initState();
		_loadContent();
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text(Preferences.localized("how_to_help")),
			),
			body: _loading ? Center(
				child: CircularProgressIndicator()
			) : Scrollbar(
				child: Markdown(
					data: _content
				),
			)
		);
}