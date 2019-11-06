import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Event settings based of course settings
class EventSettings
{
	/// Icon ID
	int icon;

	/// Event notes, for future use
	String notes;

	/// If event should be hidden, future use
	bool hidden;

	/// When the event ends and settings become invalid
	/// (in milliseconds since epoch)
	int ends;

	/// Map as <eventId, settings>
	static final _eventSettings = Map<String, EventSettings>();

	/// Default constructor
	/// (does not set notes/hidden until implemented)
	EventSettings({
		@required this.icon,
		@required this.ends
	});

	EventSettings.fromJson(Map<String, dynamic> json) :
		icon   = json["icon"],
		notes  = json["notes"],
		hidden = json["hidden"],
		ends   = json["ends"];

	Map<String, dynamic> toJson() =>
		{
			"icon":   icon,
			"notes":  notes,
			"hidden": hidden,
			"ends":   ends
		};

	/// Load event settings from file
	static Future<bool> load() async
	{
		final file = File("${(await getApplicationDocumentsDirectory()).path}/event_settings.json");
		if (!(await file.exists()))
			return false;
		_eventSettings.clear();
		_eventSettings.addAll(
			(jsonDecode(await file.readAsString()) as Map<String, dynamic>)
				.map((key, value) =>
					MapEntry<String, EventSettings>(key,
						EventSettings.fromJson(value))));

		// Remove all in the past
		final now = DateTime.now().millisecondsSinceEpoch;
		_eventSettings.removeWhere((key, value) => now > value.ends);

		return true;
	}

	/// Save event settings to file
	static void _save() async =>
		await File("${(await getApplicationDocumentsDirectory()).path}/event_settings.json")
			.writeAsString(jsonEncode(_eventSettings));

	static EventSettings get(String eventId) =>
		_eventSettings[eventId];

	/// Updates course with specified settings
	/// Also works if there are no current settings for the course
	static void set(String eventId, EventSettings settings)
	{
		if (_eventSettings.containsKey(eventId))
			_eventSettings.remove(eventId);

		_eventSettings[eventId] = settings;
		_save();
	}
}