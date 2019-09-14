import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../dialog/license_dialog.dart';
import '../dialog/login_dialog.dart';
import '../dialog/privacy_policy_dialog.dart';
import '../dialog/changelog_dialog.dart';
import '../tool/preferences.dart';

class SettingsPage extends StatefulWidget
{
	@override
	State createState() => SettingsState();
}

class SettingsState extends State<SettingsPage>
{
	/// Scaffold state for showing snack bars
	final _scaffoldKey = GlobalKey<ScaffoldState>();
	
	// For about card
	var _version = "version";
	var _build   = "build";
	
	final _languages = {
		"en": Preferences.localized("english"),
		"sv": Preferences.localized("swedish")
	};
	
	/// Build a card with children in a column
	Widget _buildCard(List<Widget> children) =>
		Card(
			child: Column(
				children: children
			),
		);
	
	/// Build title with larger text
	Widget _buildTitle(BuildContext context, String title) =>
		ListTile(
			title: Text(
				title,
				style: Theme.of(context).textTheme.title,
			)
		);
	
	/// Build a button with optional subtitle
	Widget _buildButton(String title, String subtitle, void Function() onTap) =>
		ListTile(
			title: Text(title),
			subtitle: subtitle == null ? null : Text(subtitle),
			onTap: onTap,
		);
	
	/// Build a button bar (or use as padding)
	Widget _buildButtonBar(List<Widget> children) =>
		ButtonTheme.bar(
			child: ButtonBar(
				children: children
			)
		);
	
	/// Card for general settings
	Widget _buildGeneralCard()
	{
		// Children for both Android/iOS
		final children = <Widget>[
			_buildTitle(context, Preferences.localized("title_general")),
			_buildButton(
				Preferences.localized("change_school_title"),
				Preferences.localized("change_school_info")
					.replaceFirst("{name}", Preferences.school.name), ()
			{
				showDialog(
					context: context,
					builder: (builder) =>
						AlertDialog(
							title: Text(Preferences.localized("are_you_sure")),
							content: Text(
								Preferences.localized("change_school_warning")
							),
							actions: <Widget>[
								FlatButton(
									child: Text(Preferences.localized("no")),
									onPressed: () => Navigator.of(context).pop()
								),
								FlatButton(
									child: Text(Preferences.localized("yes")),
									onPressed: ()
									{
										Navigator.of(context).pop();
										Navigator.of(context).pushReplacementNamed("/start");
									}
								)
							]
						)
				);
			}),
			SwitchListTile(
				title: Text(Preferences.localized("dark_theme_title")),
				subtitle: Text(Preferences.localized("dark_theme_info")),
				value: Preferences.darkMode,
				onChanged: (checked)
				{
					_scaffoldKey.currentState.showSnackBar(SnackBar(
						content: Text(Preferences.localized("restart_app")),
						duration: Duration(
							seconds: 2
						)
					));
					setState(() => Preferences.darkMode = checked);
				}
			),
			ListTile(
				title: Text(Preferences.localized("language_title")),
				subtitle: Text(Preferences.localized("language_info")),
				trailing: DropdownButton<String>(
					value: Preferences.locale.locale.languageCode,
					items: _languages.entries.map((value) =>
						DropdownMenuItem(
							child: Text(value.value),
							value: value.key,
						)).toList(),
					onChanged: (value) =>
						setState(() => Preferences.locale = value)
				),
			),
			_buildButtonBar([])
		];
		
		return _buildCard(children);
	}
	
	/// Card for schedule settings
	Widget _buildScheduleCard() =>
		_buildCard([
			_buildTitle(context, Preferences.localized("title_schedule")),
			SwitchListTile(
				title: Text(Preferences.localized("course_colors_title")),
				subtitle: Text(Preferences.localized("course_colors_info")),
				value: Preferences.courseColors,
				onChanged: (checked) =>
					setState(() => Preferences.courseColors = checked)
			),
			SwitchListTile(
				title: Text(Preferences.localized("week_numbers_title")),
				subtitle: Text(Preferences.localized("week_numbers_info")),
				value: Preferences.showWeek,
				onChanged: (checked) =>
					setState(() => Preferences.showWeek = checked)
			),
			SwitchListTile(
				title: Text(Preferences.localized("highlight_collisions_title")),
				subtitle: Text(
					Preferences.localized("highlight_collisions_info")
				),
				value: Preferences.showEventCollision,
				onChanged: (checked) =>
					setState(() => Preferences.showEventCollision = checked)
			),
			SwitchListTile(
				title: Text(Preferences.localized("today_view_title")),
				subtitle: Text(
					Preferences.localized("today_view_info")
				),
				value: Preferences.scheduleToday,
				onChanged: (checked) =>
					setState(() => Preferences.scheduleToday = checked)
			),
			SwitchListTile(
				title: Text(Preferences.localized("hide_duplicates_title")),
				subtitle: Text(
					Preferences.localized("hide_duplicates_info")
				),
				value: Preferences.hideDuplicates,
				onChanged: (checked) =>
					setState(() => Preferences.hideDuplicates = checked)
			),
			SwitchListTile(
				title: Text(Preferences.localized("hide_past_events_title")),
				subtitle: Text(
					Preferences.localized("hide_past_events_info")
				),
				value: Preferences.hidePastEvents,
				onChanged: (checked) =>
					setState(() => Preferences.hidePastEvents = checked)
			),
			_buildButtonBar([])
		]);
	
	/// Card for account settings
	Widget _buildAccountCard()
	{
		return _buildCard([
			_buildTitle(context, Preferences.localized("title_account")),
			_buildButton(Preferences.localized(Preferences.username == null
				? "logged_out_title" : "logged_in_title"),
				Preferences.username == null
					? Preferences.localized("logged_out_info")
					: Preferences.localized("logged_in_info")
					.replaceFirst("{username}", Preferences.username), null
			),
			_buildButton(Preferences.localized(Preferences.username == null
				? "log_in" : "log_out"),
				null, () => Preferences.username == null
					? _showLogin(context) : _logOut()),
			_buildButtonBar([])
		]);
	}
	
	/// Card for about section
	Widget _buildAboutCard()
	{
		if (_version == "version" || _build == "build")
		{
			PackageInfo.fromPlatform().then((info) =>
				setState(()
				{
					_version = "Version ${info.version}";
					_build   = "Build ${info.buildNumber}";
				}));
		}
		
		return _buildCard([
			_buildTitle(context, Preferences.localized("title_about")),
			_buildButton(_version, _build, () => _showChangelog()),
			_buildButton(Preferences.localized("privacy_policy"), null, ()
			{
				Navigator.of(context).push(MaterialPageRoute(
					builder: (builder) {
						return PrivacyPolicyDialog();
					},
					fullscreenDialog: true
				));
			}),
			_buildButton(Preferences.localized("licenses"), null, ()
			{
				Navigator.of(context).push(MaterialPageRoute(
					builder: (builder) {
						return LicenseDialog();
					},
					fullscreenDialog: true
				));
			}),
			_buildButtonBar([])
		]);
	}
	
	/// Log out (remove username and password)
	void _logOut() =>
		setState(() => Preferences.username = Preferences.password = null);
	
	/// Show login dialog
	void _showLogin(context)
	{
		if (Preferences.school.id == null)
			return;
		
		Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return LoginDialog();
			},
			fullscreenDialog: true
		));
		
		if (Preferences.username != null)
			setState(() {});
	}
	
	void _showChangelog()
	{
		Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return ChangelogDialog();
			},
			fullscreenDialog: true
		));
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			key: _scaffoldKey,
			appBar: AppBar(
				title: Text(Preferences.localized("title_settings")),
			),
			body: ListView(
				padding: EdgeInsets.all(16.0),
				children: [
					_buildGeneralCard(),
					_buildScheduleCard(),
					_buildAccountCard(),
					_buildAboutCard()
				],
			),
		);
}