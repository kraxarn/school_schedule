import 'package:flutter/material.dart';
import 'package:school_schedule/booking/booking.dart';

import '../preferences.dart';
import '../booking/booking_tabs.dart';

class BookingPage extends StatefulWidget
{
	@override
	State createState() =>
		BookingState();
}

class BookingState extends State<BookingPage>
{
	/// Current selected date
	var _date = DateTime.now();
	
	/// Shortcut for getting current date
	final _now = DateTime.now();
	
	/// Location to show in the dropdown as <id, name>
	final _locations = BookingTabs.get(Preferences.school);
	
	final _booking = Booking();
	
	var _times = List<String>();
	
	/// If progress indicator should be shown
	var _loading = false;
	
	// All results to show in the list
	var _results = List<BookingRoom>();
	
	/// Currently selected location as <id, name>
	MapEntry<String, String> _currentLocation;
	
	BookingState()
	{
		if (_locations != null)
			_currentLocation = _locations.entries.first;
	}
	
	@override
	void initState()
	{
		super.initState();
		_search();
	}
	
	/// Adds a leading zero if < 10
	String _addLeading(int value) =>
		value < 10 ? "0$value" : "$value";
	
	/// Format date as YYYY-MM-DD
	String _formatDate(DateTime date) =>
		"${date.year}-${_addLeading(date.month)}-${_addLeading(date.day)}";
	
	/// Build message for not being signed in
	Widget _buildStatusMessage(String message) =>
		Padding(
			padding: EdgeInsets.all(32.0),
			child: Text(
				message,
				textAlign: TextAlign.center,
			),
		);
	
	/// Copy date with only year, month, day
	DateTime _startOfDay(DateTime date) => 
		DateTime(
			date.year,
			date.month,
			date.day
		);
	
	/// Open date selection dialog
	void _selectDate() async
	{
		final date = await showDatePicker(
			context: context,
			initialDate: _date,
			firstDate: _startOfDay(_now),
			lastDate: _now.add(
				Duration(days: 7)
			)
		);
		
		if (date != null)
			setState(()
			{
				// Set new date
				_date = date;
				// Refresh
				_search();
			});
	}
	
	void _search() async
	{
		// Don't if we're missing stuff
		if (_locations == null || Preferences.accountId == null)
			return;
		
		// Tell we're loading
		_results.clear();
		setState(() => _loading = true);
		
		// Update from api
		final response = await _booking.get(_currentLocation.key, _date);
		
		if (response == null)
		{
			// Something went wrong
			showDialog(
				context: context,
				builder: (context) =>
					AlertDialog(
						title: Text("Error"),
						content: Text(
							"Something went wrong while loading available "
							"resources, try logging out and back in and "
							"then try again"),
						actions: <Widget>[
							FlatButton(
								child: Text("OK"),
								onPressed: () => Navigator.of(context).pop(),
							)
						],
					)
			);
		}
		else
		{
			// Save response for use later
			_times   = response.times;
			_results = response.rooms;
		}
		
		// Tell we're finished loading
		setState(() => _loading = false);
	}
	
	void _showTimesDialog(BookingRoom room)
	{
		var i = 0;
		
		showDialog(
			context: context,
			builder: (context) =>
				SimpleDialog(
					title: Text("Select time"),
					children: _times.where((time) => !Booking.isBooked(room.states[i++])).map((time) => ListTile(
						title: Text(time),
						onTap: ()
						{
							Navigator.of(context).pop();
							_showConfirmDialog(room, time);
							print("roomId: ${room.title}, timeIndex: ${_times.indexOf(time)}, timeString: $time");
						},
					)).toList(),
				)
		);
	}
	
	void _showConfirmDialog(BookingRoom room, String time)
	{
		final commentController = TextEditingController();
		
		showDialog(
			context: context,
			builder: (builder) =>
				AlertDialog(
					title: Text("Confirm"),
					content: Column(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.start,
						children: <Widget>[
							Table(
								children: [
									TableRow(
										children: [
											Text("Resource:"),
											Text(room.title)
										]
									),
									TableRow(
										children: [
											Text("Time:"),
											Text(time)
										]
									)
								],
							),
							SizedBox(
								height: 16.0,
							),
							TextField(
								controller: commentController,
								decoration: InputDecoration(
									labelText: "Comment",
									border: OutlineInputBorder(
										borderRadius: BorderRadius.all(
											Radius.circular(8.0)
										)
									)
								),
							)
						],
					),
					actions: <Widget>[
						FlatButton(
							child: Text("CANCEL"),
							onPressed: () => Navigator.of(context).pop(),
						),
						FlatButton(
							child: Text("BOOK"),
							onPressed: () {
								print("op: boka, datum: ${_formatDate(_date).substring(2)}, id: ${room.title}, typ: RESURSER_LOKALER, intervall: ${_times.indexOf(time)}, moment: ${commentController.text}, flik: FLIK_${_currentLocation.key}");
							},
						),
					],
				)
		);
	}
	
	/// Gets the first and last available time to book
	/// (this assumes there are first and last values)
	String _getFirstLastTime(BookingRoom room)
	{
		final first = room.states.indexWhere((state) =>
			!Booking.isBooked(state));
		final last  = room.states.lastIndexWhere((state) =>
			!Booking.isBooked(state));
		
		if (first < 0 || last < 0)
		{
			// If either wasn't found, log error and return nothing
			// Returning empty string instead of null because Text
			print("warning: non-booked time not found");
			return "";
		}
		
		final firstTime = _times[first].substring(
			0, _times[first].indexOf(' '));
		final lastTime  = _times[last].substring(
			_times[last].lastIndexOf(' ') + 1);
		
		return "$firstTime - $lastTime";
	}
	
	@override
	Widget build(BuildContext context)
	{
		// Check if supported school
		// TODO
		if (_locations == null)
			return _buildStatusMessage(
				"Resource booking for your selected school is currently not "
					"supported, contact me if you want to help me out"
			);
		
		// Check if logged in
		if (Preferences.accountId == null)
			return _buildStatusMessage(
				"Booking requires you to sign in from the settings"
			);
		
		// Return normal booking if logged in
		return Column(
			children: <Widget>[
				_loading ? LinearProgressIndicator(
					backgroundColor: Color.fromARGB(0, 0, 0, 0),
				) : SizedBox(),
				Card(
					child: Column(
						children: <Widget>[
							ListTile(
								title: Text("Location"),
								trailing: DropdownButton<String>(
									value: _currentLocation == null ? null : _currentLocation.value,
									onChanged: (value) => setState(()
									{
										_currentLocation = _locations.entries.firstWhere((entry) => entry.value == value);
										_search();
									}),
									items: _locations.values
										.map<DropdownMenuItem<String>>((value) =>
										DropdownMenuItem(
											child: Text(value),
											value: value
										)
									).toList()
								)
							),
							ListTile(
								title: Text("Day"),
								trailing: Text(_formatDate(_date)),
								onTap: () => _selectDate(),
							),
						],
					),
				),
				Expanded(
					child: ListView(
						children: _results.where((result) => !result.isBooked()).map((result) {
							return ListTile(
								title: Text(result.title),
								subtitle: Text(result.subtitle),
								trailing: Text("${result.states.where((state) =>
									!Booking.isBooked(state)).length} available"),
								onTap: () => _showTimesDialog(result),
							);
						}).toList(),
					),
				)
			],
		);
	}
}