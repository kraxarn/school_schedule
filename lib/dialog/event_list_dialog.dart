import 'package:flutter/material.dart';

import '../page/schedule_page.dart';
import '../tool/calendar_event.dart';
import '../tool/event_builder.dart';
import '../tool/preferences.dart';
import '../tool/date_formatter.dart';

class EventListDialog extends StatefulWidget
{
	final String _courseId;
	
	EventListDialog(this._courseId);
	
	@override
	State createState() => EventListDialogState(_courseId);
}

class EventListDialogState extends State<EventListDialog>
{
	String _courseId;
	
	List<CalendarEvent> _events;
	
	EventListDialogState(this._courseId)
	{
		_events = ScheduleState.allEvents.where((e) =>
			_courseId.contains(e.courseId)).toList();
	}
	
	/// Modified, "lighter", version of SchedulePage._buildEvents
	List<Widget> _buildEvents()
	{
		// Check if no events for saved courses
		if (_events.isEmpty)
			return EventBuilder.buildStatusMessage(
				Preferences.localized("no_events")
			);
		
		// List of all built widgets
		final now    = DateTime.now();
		final events = List<Widget>();
		
		// Temporary variables for use in loop
		var lastDate  = DateTime.utc(0);
		var lastWeek  = -1;
		
		final eventBuilder = EventBuilder(context);
		
		// Loop through all events
		for (var i = 0; i < _events.length; i++)
		{
			// Get current event
			final event = _events[i];
			
			// Check if we skipped a month
			if (lastDate.month - event.start.month > 1)
			{
				// Get exact months difference
				var diff = (((event.start.year - lastDate.year) * 12)
					+ event.start.month - lastDate.month);
				
				// Keep adding new months
				while (--diff > 0)
				{
					// Get the new date with the month reduced
					final newMonth = event.start.month - diff;
					final newDate = DateTime(
						event.start.year + (newMonth < 0 ? 1 : 0),
						newMonth < 0 ? (newMonth + 12) : newMonth
					);
					
					// Add month title
					events.add(eventBuilder.buildDateTitle(newDate));
					
					// Add "no events for this month"
					events.add(ListTile(
						title: Text(
							Preferences.localized("no_events_month"),
							style: Theme.of(context).textTheme.caption,
						),
					));
				}
			}
			
			// Check if new month
			if (lastDate.month != event.start.month
				|| lastDate.year != event.start.year)
				events.add(eventBuilder.buildDateTitle(event.start));
			
			// Week of event
			final week = DateFormatter.getWeekNumber(event.start);
			
			if (week != lastWeek && Preferences.showWeek)
				events.add(eventBuilder.buildSubtitle(
					"${Preferences.localized("week")} $week")
				);
			
			// Add to all events and set parameters
			events.add(eventBuilder.build(event, event.start.day != lastDate.day,
				EventBuilder.isSameDay(now, event.start), false));
			
			// Update for next lap
			lastDate = event.start;
			lastWeek = week;
		}
		
		return events;
	}
	
	@override
	Widget build(BuildContext context) =>
		Scaffold(
			appBar: AppBar(
				title: Text(
					Preferences.localized("events_for").replaceFirst("{course}",
						_courseId.substring(0, _courseId.indexOf('-'))
					)
				),
			),
			body: ListView(
				children: _buildEvents()
			)
		);
}