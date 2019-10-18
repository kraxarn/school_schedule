import 'package:flutter/material.dart';

import '../tool/preferences.dart';
import '../tool/date_formatter.dart';
import '../booking/booking_tabs.dart';
import '../booking/booking.dart';
import '../page/main_page.dart';
import '../dialog/booking_help_dialog.dart';

class BookingPage extends StatefulWidget
{
	@override
	State createState() =>
		BookingPageState();
}

class BookingPageState extends State<BookingPage>
{
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
		_search(updateTimes: true);
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
				title: Text(Preferences.localized("title_booking")),
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
	Future<void> _search({bool updateTimes = false}) async
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
		
		// Check if we should update times
		if (updateTimes && _times.isNotEmpty)
		{
			_startTimes = _getStartHours();
			_startTime  = _startTimes.first;
			_endTimes   = _getEndHours();
			_endTime    = _endTimes.last;
		}
		
		// Tell we're finished loading
		if (MainState.navBarIndex == 1)
			setState(() => _loading = false);
	}
	
	/// Show confirm dialog with comment entry
	void _showConfirmDialog(BookingRoom room, String time, String comment)
	{
		showDialog(
			context: context,
			builder: (builder) =>
				AlertDialog(
					title: Text(Preferences.localized("confirm")),
					content: Column(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.start,
						children: <Widget>[
							Text(
								Preferences.localized("book_confirm")
									.replaceFirst("{room}", room.title)
									.replaceFirst("{time}", time)
							)
						],
					),
					actions: <Widget>[
						FlatButton(
							child: Text(Preferences.localized("cancel")),
							onPressed: () => Navigator.of(context).pop(),
						),
						FlatButton(
							child: Text(Preferences.localized("book")),
							onPressed: () async
							{
								// We always want to dismiss the dialog
								Navigator.of(context).pop();
								
								// Check if it was successful
								if (await _booking.book(
									date:      _date,
									id:        room.title,
									timeIndex: _times.indexOf(time),
									comment:   comment,
									tabId:     _currentLocation.key
								))
								{
									// Show confirmation
									Scaffold.of(context).showSnackBar(SnackBar(
										content: Text(
											Preferences.localized("resource_booked")
										),
									));
									
									// Easiest way to collapse it again
									await _search();
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
	
	Widget _buildResourceItem(BookingRoom room) =>
		TimeSelect(_times, room, (time, comment) =>
			_showConfirmDialog(room, time, comment));
	
	/// Build list of resources
	List<Widget> _buildResourceList()
	{
		final results = _results
			.where((result) => !result.isBooked() && _isInTime(result));
		
		if (results.isEmpty)
			return [
				_loading ? SizedBox() : _buildStatusText(
					Preferences.localized("no_resources")
				)
			];
		
		return results.map((result)
		{
			final resultLength = result.states.where((state) =>
				!Booking.isBooked(state)).length;
			
			return ExpansionTile(
				title: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Text(result.title),
						Text(result.subtitle
							.replaceAll(", ", ",").replaceAll(",", ", "),
						style: Theme.of(context).textTheme.caption)
					],
				),
				trailing: Text("$resultLength "
					"${Preferences.localized(resultLength == 1
					? "booking_available" : "bookings_available")}"),
				children: <Widget>[
					Padding(
						padding: EdgeInsets.symmetric(
							horizontal: 16.0
						),
						child: _buildResourceItem(result)
					)
				],
			);
		}).toList();
	}
	
	List<int> _getStartHours() =>
		_times.map((time) => int.parse(time.substring(0, time.indexOf(':')))).toList();
	
	List<int> _getEndHours() =>
		_times.map((time) => int.parse(time.substring(time.lastIndexOf(' ') + 1, time.lastIndexOf(':')))).toList();
	
	/// Select time for filter
	void _selectTime() async
	{
		// Ignore if no times fetched yet
		if (_startTimes == null || _endTimes == null)
			return;
		
		// TODO: This is a bad solution, but it works
		final dialog = TimeFilterSelectState(
			_startTime,
			_endTime,
			_startTimes,
			_endTimes,
		);
		
		final result = await showDialog<List<int>>(
			context: context,
			builder: (builder) =>
				AlertDialog(
					title: Text(Preferences.localized("select_time_span")),
					content: TimeFilterSelectDialog(dialog),
					actions: <Widget>[
						FlatButton(
							child: Text(Preferences.localized("reset")),
							onPressed: () =>
								Navigator.of(context).pop([
									_startTimes.first, _endTimes.last
								]),
						),
						FlatButton(
							child: Text(Preferences.localized("cancel")),
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
							Preferences.localized("title_booking"),
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
							Preferences.localized("location"),
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
						_search(updateTimes: true);
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
						Preferences.localized("day"),
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
						Preferences.localized("time"),
						style: textStyle,
					),
					trailing: Text((_startTime == null || _endTime == null)
						|| (_startTime == _startTimes.first && _endTime == _endTimes.last)
						? Preferences.localized("any_time") :
							"${DateFormatter.addLeading(_startTime)}:00 - "
							"${DateFormatter.addLeading(_endTime)}:00",
						style: textStyle,
					),
					onTap: () => _selectTime()
				),
			]
		);
	}
	
	void _showBookingHelp()
	{
		Navigator.of(context).push(MaterialPageRoute(
			builder: (builder) {
				return BookingHelpDialog();
			},
			fullscreenDialog: true
		));
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
							onPressed: () => _showBookingHelp()
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
				Preferences.localized("booking_sign_in")
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
	var _booked = List<ListTile>();
	
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
					Preferences.localized("no_booked_for_location"),
					textAlign: TextAlign.center,
				),
			)
		] : bookings.map((booking) => booking.toListTile(()
		{
			showDialog(
				context: context,
				builder: (builder) =>
					AlertDialog(
						title: Text(Preferences.localized("cancel_question")),
						content: Text(
							Preferences.localized("cancel_resource_confirm")
								.replaceFirst("{location}", booking.location)
								.replaceFirst("{date}", booking.date)
								.replaceFirst("{time}", booking.timeSpan)
						),
						actions: <Widget>[
							FlatButton(
								child: Text(Preferences.localized("no")),
								onPressed: () => Navigator.of(context).pop()
							),
							FlatButton(
								child: Text(Preferences.localized("yes")),
								onPressed: () async
								{
									Navigator.of(context).pop();
									
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
								}
							),
						],
					)
			);
			
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

class TimeSelect extends StatefulWidget
{
	final BookingRoom _room;
	
	final List<String> _times;
	
	final Function(String time, String comment) _onBooked;
	
	TimeSelect(this._times, this._room, this._onBooked);
	
	@override
	State createState() =>
		TimeSelectState(_times, _room, _onBooked);
}

class TimeSelectState extends State<TimeSelect>
{
	/// Form key for comment entry when booking
	final _formCommentKey = GlobalKey<FormState>();
	
	final _commentController = TextEditingController();
	
	final BookingRoom _room;
	
	List<String> _times;
	
	String _time;
	
	final Function(String time, String comment) _onBooked;
	
	TimeSelectState(times, this._room, this._onBooked)
	{
		// Only select available times
		var i = 0;
		_times = (times.where((time) =>
			!Booking.isBooked(_room.states[i++])) as Iterable<String>).toList();
		
		// TODO: Select first that matches filter settings
		_time = _times.first;
	}
	
	DropdownButton _buildTimeSelection() =>
		DropdownButton(
			items: _times.map((time) => DropdownMenuItem(
				child: Text(time),
				value: time
			)).toList(),
			value: _time,
			onChanged: (value) => setState(() => _time = value)
		);
	
	@override
	Widget build(BuildContext context) =>
		Column(
			children: <Widget>[
				Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Text("${Preferences.localized("time")}:"),
						SizedBox(
							width: 16.0
						),
						_buildTimeSelection()
					],
				),
				SizedBox(
					height: 16.0
				),
				Form(
					key: _formCommentKey,
					child: TextFormField(
						controller: _commentController,
						decoration: InputDecoration(
							labelText: Preferences.localized("comment"),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.all(
									Radius.circular(8.0)
								)
							)
						),
						validator: (value) =>
						value.isEmpty ? Preferences.localized("required") : null
					),
				),
				ButtonTheme.bar(
					child: ButtonBar(
						children: [
							FlatButton(
								child: Text(Preferences.localized("book")),
								onPressed: ()
								{
									// Check if comment is entered
									if (!_formCommentKey.currentState.validate())
										return;
									
									// Call function from parent
									_onBooked(_time, _commentController.text);
								},
							)
						]
					)
				)
			],
		);
}

/// Widget for selecting time used in filter settings
class TimeFilterSelectDialog extends StatefulWidget
{
	final TimeFilterSelectState _state;
	
	TimeFilterSelectDialog(this._state);
	
	@override
	State createState() => _state;
}

class TimeFilterSelectState extends State<TimeFilterSelectDialog>
{
	int start;
	int end;
	
	List<int> _starts;
	List<int> _ends;
	
	TimeFilterSelectState(this.start, this.end, this._starts, this._ends);
	
	@override
	Widget build(BuildContext context) => 
		Table(
			children: [
				TableRow(
					children: [
						ListTile(
							title: Text(Preferences.localized("from")),
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
							title: Text(Preferences.localized("to")),
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