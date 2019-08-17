
import 'package:school_schedule/calendar_event.dart';

class Demo
{
	/// Calendar events for testing on schedule page
	static List<CalendarEvent> get calendarEvents =>
		[
			CalendarEvent(
				"DTSTART:20190910T101500\n"
					"DTEND:20190910T1200000\n"
					"LAST-MODIFIED:20190910T101500\n"
					"LOCATION:Zeta\n"
					"UID:001\n"
					"SUMMARY:Kurs.grp: DVA217 Sign: aaa001 Moment: Lecture 1 Aktivitetstyp: Okänd\n"
			),
			CalendarEvent(
				"DTSTART:20190917T131500\n"
					"DTEND:20190917T1500000\n"
					"LAST-MODIFIED:20190917T131500\n"
					"LOCATION:Zeta\n"
					"UID:002\n"
					"SUMMARY:Kurs.grp: DVA217 Sign: aaa001 Moment: Lecture 2 Aktivitetstyp: Okänd\n"
			),
			CalendarEvent(
				"DTSTART:20190919T131500\n"
					"DTEND:20190919T1700000\n"
					"LAST-MODIFIED:20190919T131500\n"
					"LOCATION:U2-127\n"
					"UID:003\n"
					"SUMMARY:Kurs.grp: DVA217 Sign: aaa001 Moment: Lab 1 Aktivitetstyp: Okänd\n"
			),
			CalendarEvent(
				"DTSTART:20190926T101500\n"
					"DTEND:20190926T1200000\n"
					"LAST-MODIFIED:20190926T101500\n"
					"LOCATION:U2-127\n"
					"UID:004\n"
					"SUMMARY:Kurs.grp: DVA217 Sign: aaa001 Moment: Lab 2 Aktivitetstyp: Okänd\n"
			),
			CalendarEvent(
				"DTSTART:20191003T101500\n"
					"DTEND:20191003T1200000\n"
					"LAST-MODIFIED:20191003T101500\n"
					"LOCATION:Zeta\n"
					"UID:005\n"
					"SUMMARY:Kurs.grp: DVA217 Sign: aaa001 Moment: Lecture 3 Aktivitetstyp: Okänd\n"
			),
			CalendarEvent(
				"DTSTART:20191005T131500\n"
					"DTEND:20191005T1700000\n"
					"LAST-MODIFIED:20191005T131500\n"
					"LOCATION:U2-127\n"
					"UID:006\n"
					"SUMMARY:Kurs.grp: DVA217 Sign: aaa001 Moment: Lab 3 Aktivitetstyp: Okänd\n"
			)
		];
}