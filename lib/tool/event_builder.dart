import 'package:flutter/material.dart';

import '../tool/calendar_event.dart';
import '../tool/preferences.dart';
import '../tool/course_name.dart';
import '../tool/user_colors.dart';
import '../tool/date_formatter.dart';

class EventBuilder
{
	BuildContext _context;
	
	EventBuilder(this._context);
	
	/// If the date occurs within the event
	static bool isWithin(DateTime date, CalendarEvent event) =>
		event.start.difference(date).isNegative
			&& !event.end.difference(date).isNegative;
	
	static bool isSameDay(DateTime d1, DateTime d2) =>
		d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
	
	/// Get 3 character name of weekday
	static String weekdayToString(int weekday) =>
		Preferences.localized("week_days").split(',')[weekday - 1];
	
	String _getDaysTo(DateTime d1, DateTime d2)
	{
		final diff  = d1.difference(d2);
		final days  = diff.inDays;
		final hours = diff.inHours;
		
		if (days != 0)
			return "${Preferences.localized(days > 0
				? "time_in" : "time_was_ago").replaceFirst("{time}",
				"${days < 0 ? -days : days} ${Preferences.localized(
					days == 1 ? "day" : "days").toLowerCase()}")}";
		
		return "${Preferences.localized(hours > 0
			? "time_in" : "time_was_ago").replaceFirst("{time}",
			"${hours < 0 ? -hours : hours} ${Preferences.localized(
				hours == 1 ? "hour" : "hours")}")}";
	}
	
	/// Build an empty table row
	TableRow _buildEventDivider() =>
		TableRow(
			children: [
				Divider(),
				Divider(),
				Divider()
			]
		);
	
	/// Build table row for event info
	TableRow _buildEventInfoRow(IconData icon, String title, String info) =>
		TableRow(
			children: [
				Icon(icon),
				Text(
					title,
					style: Theme.of(_context).textTheme.subtitle,
				),
				Text(info ?? "(none)")
			]
		);
	
	Widget build(CalendarEvent event, bool printDate,
		bool isToday, bool highlightTime) =>
		ExpansionTile(
			leading: printDate ? Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Text(
						weekdayToString(event.start.weekday),
						style: Theme.of(_context).textTheme.caption.copyWith(
							color: isToday ? Theme.of(_context).accentColor : null
						),
					),
					Text(
						event.start.day.toString(),
						style: TextStyle(
							color: isToday ? Theme.of(_context).accentColor : null
						),
					)
				],
			
			) : SizedBox(),
			title: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					// Title
					Text(
						event.summary,
						style: TextStyle(
							color: UserColors().getColor(event.courseId).color
						)
					),
					// Subtitle
					Text(
						"${DateFormatter.asTime(event.start)} - "
							"${DateFormatter.asTime(event.end)}",
						style: Theme.of(_context).textTheme.caption.copyWith(
							color: highlightTime ? Colors.red : null,
							fontWeight: isWithin(DateTime.now(), event)
								? FontWeight.bold : null,
							decoration: event.end.difference(DateTime.now()).isNegative
								? TextDecoration.lineThrough : null
						),
					)
				],
			),
			trailing: Text(
				"${event.courseId.split('-')[0]}\n"
					"${event.location.split(' ')[0]}",
				textAlign: TextAlign.end
			),
			children: <Widget>[
				Padding(
					padding: EdgeInsets.all(16.0),
					child: Table(
						defaultVerticalAlignment: TableCellVerticalAlignment.middle,
						columnWidths: {
							0: FixedColumnWidth(48.0)
						},
						children: [
							_buildEventInfoRow(
								Icons.school,
								Preferences.localized("course_code"),
								event.courseId
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.text_fields,
								Preferences.localized("course_name"),
								CourseName.get(event.fullCourseId)
									?? Preferences.localized("none")
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.account_circle,
								Preferences.localized("signature"),
								event.signature
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.location_on,
								Preferences.localized("locations"),
								event.location.isEmpty
									? Preferences.localized("none")
									: event.location.replaceAll(" ", ", ")
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.timelapse,
								Preferences.localized("date_time"),
								"${DateFormatter.asFullDateTime(event.start)} - "
									"${isSameDay(event.start, event.end)
									? DateFormatter.asTime(event.end)
									: DateFormatter.asFullDateTime(event.end)}\n(${_getDaysTo(event.start, DateTime.now())})"
							),
							_buildEventDivider(),
							_buildEventInfoRow(
								Icons.edit,
								Preferences.localized("last_modified"),
								DateFormatter.asFullDateTime(event.lastModified)
							)
						]
					)
				)
			]
		);
}