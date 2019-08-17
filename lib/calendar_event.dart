import 'package:http/http.dart' as http;
import 'package:school_schedule/school.dart';

/*
 * iCal properties:
 * DTSTART			= Start date and time
 * DTEND			= End date and time
 * DTSTAMP			= When the instance was created
 * UID				= Unique ID
 * CREATED			= When the info was created
 * LAST-MODIFIED	= When the component was last revised
 * LOCATION			= Location of event
 * SEQUENCE			= Revision sequence number
 * STATUS			= Overall status or confirmation
 * SUMMARY			= Event subject
 * TRANSP			= Transparent or not to busy time searches
 * X-GWSHOW-AS		= Unknown non-standard property
 */

class CalendarEvent
{
	/// ID used with device calendar
	String _id;
	
	/// Date and time of start
	DateTime _start;
	DateTime get start => _start;
	
	/// Date and time of end
	DateTime _end;
	DateTime get end => _end;
	
	/// When the event was last revised
	DateTime _lastModified;
	DateTime get lastModified => _lastModified;
	
	/// Location of the event
	String _location;
	String get location => _location;
	
	/// Summary or subject
	/// TODO: Parse summary nicer
	String _summary;
	String get summary => _summary;
	
	/// Course ID / course code
	String _courseId;
	String get courseId => _courseId;
	
	String get fullCourseId =>
		_courseId.contains(' ')
			? _courseId.substring(_courseId.indexOf(' ') + 1) : _courseId;
	
	/// Signature / who created it
	String _signature;
	String get signature => _signature;
	
	/// Substring between start and end of text
	String _between(String text, String start, String end) =>
		text.substring(
			text.indexOf(start) + start.length,
			text.indexOf(end)
		).trim();
	
	/// Parses a single event
	CalendarEvent(String data)
	{
		data.split('\n').forEach((line) {
			final l = line.split(':');
			switch (l[0])
			{
				case "DTSTART":
					_start = _parseDateTime(l[1]);
					break;
					
				case "DTEND":
					_end = _parseDateTime(l[1]);
					break;
					
				case "LAST-MODIFIED":
					_lastModified = _parseDateTime(l[1]);
					break;
					
				case "LOCATION":
					_location = l[1].trim();
					break;
					
				case "UID":
					_id = l[1].trim();
					break;
					
				case "SUMMARY":
					/*
					 * TODO: This could possible be done better
					 * Assume:
					 * SUMMARY: Kurs.grp:<course-id> Sign:<signature> Moment:<summary>
					 */
					_courseId  = _between(line, "Kurs.grp:", "Sign");
					_signature = _between(line, "Sign:", "Moment");
					_summary   = _between(line, "Moment:", "Aktivitetstyp");
					break;
			}
		});
	}
	
	/// Parse iCal date
	/// WARNING: This assumes UTC+2 time zone
	DateTime _parseDateTime(String data)
	{
		data = data.trim();
		
		// Dart's DateTime.parse doesn't work, so we have to make our own
		return DateTime(
			// Year
			int.parse(data.substring(0, 4)),
			// Month
			int.parse(data.substring(4, 6)),
			// Day
			int.parse(data.substring(6, 8)),
			// Hour
			// (add 2 if Z (UTC) / convert to UTC+2)
			int.parse(data.substring(9, 11)) + (data.endsWith('Z') ? 2 : 0),
			// Minute
			int.parse(data.substring(11, 13)),
			// Second (prob not needed, but why not)
			int.parse(data.substring(13, 15)),
		);
	}
	
	/// DateTime to int
	static int _encodeDate(DateTime value) =>
		value.millisecondsSinceEpoch;
	
	/// int to DateTime
	static DateTime _decodeDate(int value) =>
		DateTime.fromMillisecondsSinceEpoch(value);
	
	CalendarEvent.fromJson(Map<String, dynamic> json) : _start = _decodeDate(json["start"]),
			_end = _decodeDate(json["end"]), _lastModified = _decodeDate(json["last_modified"]),
			_location = json["location"], _summary = json["summary"],
			_courseId = json["course_id"], _signature = json["signature"];
	
	Map<String, dynamic> toJson() =>
		{
			"uid":           _id,
			"start":         _encodeDate(_start),
			"end":           _encodeDate(_end),
			"last_modified": _encodeDate(_lastModified),
			"location":      _location,
			"summary":       _summary,
			"course_id":     _courseId,
			"signature":     _signature
		};
	
	/// Parse all events in an ICS file
	static List<CalendarEvent> parseMultiple(String data)
	{
		// Split up for every event
		final events = data.split("BEGIN:VEVENT");
		
		// Remove first since that's just ICS data
		events.removeAt(0);
		
		// Return final list with events
		return events.map((event) {
			return CalendarEvent(event);
		}).toList();
	}
	
	/// Get ICS calendar for specified course
	static Future<String> getCalendar(http.Client http, School school, String courseId) =>
		http.read(
			"${school.baseUrl}setup/jsp/SchemaICAL.ics?"
			"startDatum=idag&intervallTyp=a&intervallAntal=1&sprak=SV"
			"&sokMedAND=true&forklaringar=true&resurser=k.$courseId"
		);
}