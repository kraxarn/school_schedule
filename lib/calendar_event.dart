import 'package:http/http.dart' as http;

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
	
	/// Course ID for helping later
	/// (currently not fetched from ICS)
	/// TODO: Course ID can be fetched from summary
	String courseId;
	
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
					_location = l[1].trim().replaceAll(" ", ", ");
					break;
					
				case "SUMMARY":
					/*
					 * TODO: Here we actually want to get each part
					 *  and put it somewhere separately, but for now, we
					 *  just put the interesting stuff and also assume what
					 *  ends it
					 */
					_summary = line.substring(line.indexOf("Moment:") + 7, line.indexOf("Aktivitetstyp")).trim();
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
	static Future<String> getCalendar(String schoolId, String courseId) =>
		http.read("https://webbschema.$schoolId.se/setup/jsp/SchemaICAL.ics?"
			"startDatum=idag&intervallTyp=a&intervallAntal=1&sprak=SV"
			"&sokMedAND=true&forklaringar=true&resurser=k.$courseId");
}