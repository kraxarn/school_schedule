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
	/// Form key for comment entry when booking
	final _formCommentKey = GlobalKey<FormState>();
	
	/// Current selected date
	var _date = DateTime.now();
	
	/// Shortcut for getting current date
	final _now = DateTime.now();
	
	/// Location to show in the dropdown as <id, name>
	final _locations = BookingTabs.get(Preferences.school.id);
	
	/// Booking instance for various API calls
	final _booking = Booking();
	
	// All time intervals
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
	
	/// Perform search
	void _search() async
	{
		// Don't if we're missing stuff
		if (_locations == null || Preferences.username == null)
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
							"resources, try restarting the app and "
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
	
	/// Show dialog for picking time after selecting resource
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
	
	/// Show confirm dialog with comment entry
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
							Text(
								"Are you sure you want to book resource "
								"${room.title} at $time?"
							),
							SizedBox(
								height: 16.0,
							),
							Form(
								key: _formCommentKey,
								child: TextFormField(
									controller: commentController,
									decoration: InputDecoration(
										labelText: "Comment",
										border: OutlineInputBorder(
											borderRadius: BorderRadius.all(
												Radius.circular(8.0)
											)
										)
									),
									validator: (value) =>
										value.isEmpty ? "Required" : null
								),
							),
						],
					),
					actions: <Widget>[
						FlatButton(
							child: Text("CANCEL"),
							onPressed: () => Navigator.of(context).pop(),
						),
						FlatButton(
							child: Text("BOOK"),
							onPressed: () async
							{
								// Check if comment is entered
								if (!_formCommentKey.currentState.validate())
									return;
								
								// Dismiss dialog
								Navigator.of(context).pop();
								
								// Check if it was successful
								if (await _booking.book(
									date:      _date,
									id:        room.title,
									timeIndex: _times.indexOf(time),
									comment:   commentController.text,
									tabId:     _currentLocation.key
								))
								{
									Scaffold.of(context).showSnackBar(SnackBar(
										content: Text("Resource booked"),
									));
								}
								else
									showDialog(
										context: context,
										builder: (builder) =>
											AlertDialog(
												title: Text("Error"),
												content: Text(
													"Something went wrong when "
														"booking the resource, "
														"maybe you reached your "
														"booking limit?"
												),
												actions: <Widget>[
													FlatButton(
														child: Text("OK"),
														onPressed: () => Navigator.of(context).pop(),
													)
												],
											)
									);
							},
						),
					],
				)
		);
	}
	
	void _showBookedResources()
	{
		showModalBottomSheet(
			context: context,
			builder: (builder) => BookedResourcesDialog(
				_booking, _currentLocation.key)
		);
	}
	
	/// Build list of resources
	List<Widget> _buildResourceList()
	{
		final results = _results.where((result) => !result.isBooked());
		
		if (results.isEmpty)
			return [
				_loading ? SizedBox() : _buildStatusMessage(
					"No available resources found for the "
						"specified location and day"
				)
			];
		
		return results.map((result) {
			return ListTile(
				title: Text(result.title),
				subtitle: Text(result.subtitle
					.replaceAll(", ", ",").replaceAll(",", ", ")),
				trailing: Text("${result.states.where((state) =>
					!Booking.isBooked(state)).length} available"),
				onTap: () => _showTimesDialog(result),
			);
		}).toList();
	}
	
	Widget _buildFilterSettings()
	{
		final textStyle = TextStyle(
			color: Colors.white
		);
		
		return ListView(
			children: <Widget>[
				ListTile(
					title: Text(
						"Booking",
						style: Theme.of(context).textTheme.title.apply(
							color: Colors.white
						),
					),
					trailing: IconButton(
						icon: Icon(
							Icons.list,
							color: Colors.white,
						),
						onPressed: () => _showBookedResources(),
					),
				),
				// Location tile
				ListTile(
					leading: Icon(
						Icons.location_on,
						color: Colors.white,
					),
					title: Text(
						"Location",
						style: textStyle,
					),
					trailing: PopupMenuButton(
						child: _currentLocation == null
							? null : Text(
							_currentLocation.value,
							style: textStyle,
						),
						itemBuilder: (builder) => _locations.values
							.map<PopupMenuItem<String>>((value) =>
							PopupMenuItem(
								child: Text(
									value
								),
								value: value,
							)
						).toList(),
						onSelected: (value)
						{
							setState(() =>
								_currentLocation = _locations.entries
									.firstWhere((entry) =>
										entry.value == value));
							_search();
						},
					),
				),
				// Day tile
				ListTile(
					leading: Icon(
						Icons.today,
						color: Colors.white,
					),
					title: Text(
						"Day",
						style: textStyle,
					),
					trailing: Text(
						_formatDate(_date),
						style: textStyle,
					),
					onTap: () => _selectDate()
				)
			]
		);
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
		if (Preferences.username == null)
			return _buildStatusMessage(
				"Booking requires you to sign in from the settings"
			);
		
		return Scaffold(
			body: NestedScrollView(
				headerSliverBuilder: (context, scrolled) =>
				[
					SliverAppBar(
						pinned:   true,
						snap:     true,
						floating: true,
						expandedHeight: 168.0,
						flexibleSpace: _buildFilterSettings(),
					),
				],
				body: ListView(
					padding: EdgeInsets.all(0.0),
					children: _loading ? [
						LinearProgressIndicator(
							backgroundColor: Color.fromARGB(0, 0, 0, 0),
						)
					] : _buildResourceList(),
				),
			),
		);
	}
}

class BookedResourcesDialog extends StatefulWidget
{
	final Booking _booking;
	
	final String _tabId;
	
	@override
	State createState() => BookedResourcesState(_booking, _tabId);
	
	BookedResourcesDialog(this._booking, this._tabId);
}

class BookedResourcesState extends State<BookedResourcesDialog>
{
	/// Resources booked list
	var _booked = List<Widget>();
	
	/// Instance of Booking to get bookings
	final Booking _booking;
	
	/// Tab to get bookings for
	final String _tabId;
	
	BookedResourcesState(this._booking, this._tabId);
	
	/// Refresh resource list
	void _refreshBookedResources() async
	{
		// When enabling, fetch stuff
		final bookings = await _booking.getBookings(
			date: DateTime.now(),
			tabId: _tabId
		);
		
		setState(() =>
		_booked = bookings == null ? [
			ListTile(
				title: Text(
					"No results found for the specified location",
					textAlign: TextAlign.center,
				),
			)
		] : bookings.map((booking) => booking.toListTile(() async
		{
			if (!await _booking.cancel(booking.id))
				showDialog(
					context: context,
					builder: (builder) =>
						AlertDialog(
							title: Text("Error"),
							content: Text(
								"There was an error canceling the "
									"selected resource"
							),
							actions: <Widget>[
								FlatButton(
									child: Text("OK"),
									onPressed: () =>
										Navigator.of(context).pop(),
								)
							],
						)
				);
			else
				_refreshBookedResources();
		})).toList());
	}
	
	@override
	void initState()
	{
		super.initState();
		_refreshBookedResources();
	}
	
	@override
	Widget build(BuildContext context) =>
		_booked.isEmpty ? Padding(
			padding: EdgeInsets.all(32.0),
			child: LinearProgressIndicator()
		) : SizedBox(
			height: 240.0,
			child: ListView(
				children: _booked,
			)
		);
}