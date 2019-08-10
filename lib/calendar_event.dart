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
	String _summary;
	String get summary => _summary;
	
	/// Course ID for helping later
	/// (currently not fetched from ICS)
	String courseId;
	
	/// Parses a single event
	CalendarEvent(String data)
	{
		data.split('\n').forEach((line) {
			final l = line.split(':');
			switch (l[0])
			{
				case "DTSTART":
					_start = DateTime.parse(l[1]);
					break;
					
				case "DTEND":
					_end = DateTime.parse(l[2]);
					break;
					
				case "LAST-MODIFIED":
					_lastModified = DateTime.parse(l[1]);
					break;
					
				case "LOCATION":
					_location = l[1].trim();
					break;
					
				case "SUMMARY":
					_summary = l[1].trim();
					break;
			}
		});
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
		});
	}
	
	/// Get ICS calendar for specified course
	static Future<String> getCalendar(String schoolId, String courseId) =>
		http.read("https://kronox.$schoolId.se/setup/jsp/SchemaICAL.ics?"
			"startDatum=idag&intervallTyp=a&intervallAntal=1&sprak=SV"
			"&sokMedAND=true&forklaringar=true&resurser=k.$courseId");
}