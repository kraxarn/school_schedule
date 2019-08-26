import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tool/preferences.dart';
import '../tool/date_formatter.dart';
import '../booking/booking_tabs.dart';
import '../booking/booking.dart';
import '../page/main_page.dart';

class BookingPage extends StatefulWidget
{
	@override
	State createState() =>
		BookingPageState();
}

class BookingPageState extends State<BookingPage>
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
	
	/// All results to show in the list
	var _results = List<BookingRoom>();
	
	/// All available start times
	List<int> _startTimes;
	
	/// Selected start time
	int _startTime;
	
	/// All available end times
	List<int> _endTimes;
	
	/// Selected end time
	int _endTime;
	
	/// Currently selected location as <id, name>
	MapEntry<String, String> _currentLocation;
	
	BookingPageState()
	{
		// TODO: Constructor or initState?
		if (Preferences.lastLocation != null
			&& _locations != null
			&& _locations.containsKey(Preferences.lastLocation))
			_currentLocation = _locations.entries
				.firstWhere((entry) => entry.key == Preferences.lastLocation);
		else if (_locations != null)
			_currentLocation = _locations.entries.first;
	}
	
	@override
	void initState()
	{
		super.initState();
		
		_search().then((_)
		{
			// Load times after search is complete
			// (otherwise _times isn't loaded)
			if (_times.isNotEmpty)
			{
				_startTimes = _getStartHours();
				_startTime  = _startTimes.first;
				_endTimes   = _getEndHours();
				_endTime    = _endTimes.last;
			}
		});
		
	}
	
	/// Builds a padded, centered text
	Widget _buildStatusText(String message) =>
		Padding(
			padding: EdgeInsets.all(32.0),
			child: Align(
				alignment: Alignment.topCenter,
				child: Text(
					message,
					textAlign: TextAlign.center,
				)
			),
		);
	
	/// Builds status message including scaffold
	Widget _buildStatusMessage(String message) =>
		Scaffold(
			appBar: AppBar(
				title: Text("Booking"),
			),
			body: _buildStatusText(message)
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
	Future<void> _search() async
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
							"resources, check your connection and "
							"try again"),
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
		if (MainState.navBarIndex == 1)
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
					children: _times.where((time) =>
					!Booking.isBooked(room.states[i++]))
					.map((time) => ListTile(
						title: Text(time),
						onTap: ()
						{
							Navigator.of(context).pop();
							_showConfirmDialog(room, time);
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
	
	bool _isInTime(BookingRoom room)
	{
		for (var i = 0; i < room.states.length; i++)
		{
			// Shortcut for getting state
			final state = room.states[i];
			
			// Ignore if not free
			if (state != BookingState.free)
				continue;
			
			// Check if it's within the selected time span
			if (_startTimes[i] >= _startTime && _endTimes[i] <= _endTime)
				return true;
		}
		
		return false;
	}
	
	/// Build list of resources
	List<Widget> _buildResourceList()
	{
		final results = _results
			.where((result) => !result.isBooked() && _isInTime(result));
		
		if (results.isEmpty)
			return [
				_loading ? SizedBox() : _buildStatusText(
					"No available resources found that matches "
						"the specified options"
				)
			];
		
		return results.map((result) =>
			ListTile(
				title: Text(result.title),
				subtitle: Text(result.subtitle
					.replaceAll(", ", ",").replaceAll(",", ", ")),
				trailing: Text("${result.states.where((state) =>
					!Booking.isBooked(state)).length} available"),
				onTap: () => _showTimesDialog(result),
			)).toList();
	}
	
	List<int> _getStartHours() =>
		_times.map((time) => int.parse(time.substring(0, time.indexOf(':')))).toList();
	
	List<int> _getEndHours() =>
		_times.map((time) => int.parse(time.substring(time.lastIndexOf(' ') + 1, time.lastIndexOf(':')))).toList();
	
	/// Select time for filter
	void _selectTime() async
	{
		// Ignore if loading
		if (_loading)
			return;
		
		// TODO: This is a bad solution, but it works
		final dialog = TimeSelectState(
			_startTime,
			_endTime,
			_startTimes,
			_endTimes,
		);
		
		final result = await showDialog<List<int>>(
			context: context,
			builder: (builder) =>
				AlertDialog(
					title: Text("Select time span"),
					content: TimeSelectDialog(dialog),
					actions: <Widget>[
						FlatButton(
							child: Text("RESET"),
							onPressed: () =>
								Navigator.of(context).pop([
									_startTimes.first, _endTimes.last
								]),
						),
						FlatButton(
							child: Text("CANCEL"),
							onPressed: () =>
								Navigator.of(context).pop(),
						),
						FlatButton(
							child: Text("OK"),
							onPressed: () =>
								Navigator.of(context).pop([
									dialog.start, dialog.end
								]),
						)
					],
				)
		);
		
		if (result != null)
		{
			setState(()
			{
				_startTime = result[0];
				_endTime   = result[1];
			});
			_search();
		}
	}
	
	Widget _buildFilterSettings()
	{
		final textStyle = TextStyle(
			color: Colors.white
		);
		
		return ListView(
			children: <Widget>[
				ListTile(
					title: Padding(
						padding: EdgeInsets.only(
							left: 16.0
						),
						child: Text(
							"Booking",
							style: Theme.of(context).textTheme.title.apply(
								color: Colors.white
							),
						),
					),
					contentPadding: EdgeInsets.all(0.0),
					trailing: IconButton(
						icon: Icon(
							Icons.list,
							color: Colors.white,
						),
						onPressed: () => _showBookedResources(),
					),
				),
				// Location tile
				PopupMenuButton(
					offset: Offset.fromDirection(0.0),
					child: ListTile(
						leading: Icon(
							Icons.location_on,
							color: Colors.white,
						),
						title: Text(
							"Location",
							style: textStyle,
						),
						trailing: Text(
							_currentLocation.value,
							style: textStyle,
						),
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
						Preferences.lastLocation = _currentLocation.key;
					}
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
						DateFormatter.asFullDate(_date),
						style: textStyle,
					),
					onTap: () => _selectDate()
				),
				// Time tile
				ListTile(
					leading: Icon(
						Icons.timelapse,
						color: Colors.white,
					),
					title: Text(
						"Time",
						style: textStyle,
					),
					trailing: Text((_startTime == null || _endTime == null)
						|| (_startTime == _startTimes.first && _endTime == _endTimes.last)
						? "Any" :
							"${DateFormatter.addLeading(_startTime)}:00 - "
							"${DateFormatter.addLeading(_endTime)}:00",
						style: textStyle,
					),
					onTap: () => _selectTime()
				),
			]
		);
	}
	
	Widget _buildNotSupportedPage() =>
		Scaffold(
			appBar: AppBar(
				title: Text("Booking"),
			),
			body: Padding(
				padding: EdgeInsets.all(32.0),
				child: Column(
					children: <Widget>[
						Text(
							"Resource booking for your selected school is "
								"currently not supported",
							textAlign: TextAlign.center,
						),
						SizedBox(
							height: 32.0,
						),
						RaisedButton(
							child: Text("I want to help!"),
							onPressed: () =>
								launch(
									"https://github.com/kraxarn/"
										"school_schedule/wiki/"
										"How-to-help-with-booking"
								),
						),
						Text(
							"(it's not difficult)",
							style: Theme.of(context).textTheme.caption,
						)
					],
				),
			)
		);
	
	@override
	Widget build(BuildContext context)
	{
		// Check if supported school
		// TODO
		if (Preferences.school.id == null)
			return _buildStatusMessage(
				"Resource booking is currently not supported when having "
					"the demo school selected"
			);
		if (_locations == null)
			return _buildNotSupportedPage();
		
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
						expandedHeight: 224.0,
						flexibleSpace: _buildFilterSettings(),
					),
				],
				body: RefreshIndicator(
					child: ListView(
						padding: EdgeInsets.all(0.0),
						children: _loading ? [
							LinearProgressIndicator(
								backgroundColor: Color.fromARGB(0, 0, 0, 0),
							)
						] : _buildResourceList(),
					),
					onRefresh: () => _search(),
				)
			)
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
					"No booked resources found for the specified location",
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

class TimeSelectDialog extends StatefulWidget
{
	final TimeSelectState _state;
	
	TimeSelectDialog(this._state);
	
	@override
	State createState() => _state;
}

class TimeSelectState extends State<TimeSelectDialog>
{
	int start;
	int end;
	
	List<int> _starts;
	List<int> _ends;
	
	TimeSelectState(this.start, this.end, this._starts, this._ends);
	
	@override
	Widget build(BuildContext context) => 
		Table(
			children: [
				TableRow(
					children: [
						ListTile(
							title: Text("From"),
							trailing: DropdownButton(
								items: _starts.where((time) => time < end)
									.map((time) =>
										DropdownMenuItem(
											value: time,
											child: Text(
												"${DateFormatter.addLeading(time)}:00"
											),
										)
									).toList(),
								value: start,
								onChanged: (value) {
									setState(() => start = value);
								},
							),
						)
					]
				),
				TableRow(
					children: [
						ListTile(
							title: Text("To"),
							trailing: DropdownButton(
								items: _ends.where((time) => time > start)
									.map((time) =>
										DropdownMenuItem(
											value: time,
											child: Text(
												"${DateFormatter.addLeading(time)}:00"
											),
										)
									).toList(),
								value: end,
								onChanged: (value) => setState(() => end = value),
							),
						)
					]
				)
			],
		);
}