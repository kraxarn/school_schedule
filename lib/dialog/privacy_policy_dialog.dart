import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class PrivacyPolicyDialog extends StatefulWidget
{
	@override
	State createState() =>
		PrivacyPolicyState();
}

class PrivacyPolicyState extends State<PrivacyPolicyDialog>
{
	/// If we're currently loading the privacy policy
	var _loading = true;
	
	/// String the privacy policy will be written to later
	var _privacyPolicy = "";
	
	@override
	void initState()
	{
		super.initState();
		
		// We start fetching it ahead of time
		http.read("https://kronox.se/app/privacypolicy.php").then((response) {
			setState(() {
				_privacyPolicy = response.substring(
					response.indexOf("</head>") + 7,
					response.indexOf("</html>")
				).replaceAll("<h2>", "## ").replaceAll("</h2>", "").trim();
				_loading = false;
			});
		});
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text("Privacy Policy"),
			),
			// Show centered progress indicator while loading
			body: _loading ? Center(
				child: CircularProgressIndicator()
			) : Scrollbar(
				child: Markdown(
					data: _privacyPolicy
				),
			)
		);
}