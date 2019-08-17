import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:school_schedule/preferences.dart';

enum BookingState
{
	/// Already booked by someone
	busy,
	/// Free to book
	free,
	/// Time has passed
	passed,
	/// Fallback
	unknown
}

class Booking
{
	final _http = HttpClient();
	
	Future<String> _get(String url) async
	{
		final request = await _http.getUrl(Uri.parse(url));
		request.cookies.add(await Preferences.sessionCookie);
		final response = await request.close();
		return await response.transform(utf8.decoder).join();
	}
	
	/// Adds a leading zero if < 10
	String _addLeading(int value) =>
		value < 10 ? "0$value" : "$value";
	
	/// Formats date as YY-MM-DD
	String _formatDate(DateTime date) =>
		"${date.year.toString().substring(2)}-${_addLeading(date.month)}-${_addLeading(date.day)}";
	
	/// If the specified state counts as booked
	static bool isBooked(BookingState state) =>
		state != BookingState.free;
	
	BookingState _getStateFromClasses(dom.CssClassSet classes)
	{
		for (final className in classes)
		{
			// It's probably only grupprum-*, but to be sure
			if (className.contains("passerad"))
				return BookingState.passed;
			if (className.contains("upptagen"))
				return BookingState.busy;
			if (className.contains("ledig"))
				return BookingState.free;
		}
		
		print("warning: unknown state ($classes)");
		return BookingState.unknown;
	}
	
	/// Get all available bookings
	/// tabId should be four numbers (0000 for example)
	/// Only year, month and date is used for date
	Future<BookingResponse> get(String tabId, DateTime date) async
	{
		final response = await _get(
			"https://webbschema.${Preferences.school}.se/"
				"ajax/ajax_resursbokning.jsp?flik=FLIK_$tabId"
				"&op=hamtaBokningar"
				"&datum=${_formatDate(date)}"
		);
		
		if (response.contains("inte rättigheter"))
		{
			print("error: no permissions to fetch page");
			return null;
		}
		
		final html = parse(response);
		//                 <html>     <body>      <table>    <tbody>    <tr>
		final table = html.firstChild.children[1].firstChild.firstChild.children;
		
		List<String> times;
		final rooms = List<BookingRoom>();
		
		for (final row in table)
		{
			// First row is the times
			if (times == null)
			{
				// Every column contains a <b>, get the text in it
				times = row.children.map((child) => child.firstChild.text).toList();
				// The first column is empty
				times.removeAt(0);
				// Done with this row
				continue;
			}
			
			// Loop though the columns
			String title, subtitle;
			final states = List<BookingState>();
			for (final column in row.children)
			{
				// First column is title/subtitles
				if (title == null || subtitle == null)
				{
					final html = column.innerHtml;
					// <b>title</b> <small>subtitles</small>
					title = html.substring(
						html.indexOf("<b>") + 3, html.indexOf("</b>")
					);
					subtitle = html.substring(
						html.indexOf("<small>") + 7, html.indexOf("</small>")
					);
					continue;
				}
				
				// The rest are the times
				// TODO: If free, we probably want to get the js call
				states.add(_getStateFromClasses(column.classes));
			}
			
			rooms.add(BookingRoom(title, subtitle, states));
		}
		
		return BookingResponse(times, rooms);
	}
	
	Future<bool> book({DateTime date, String id, int timeIndex, String comment, String tabId}) async =>
		(await _get(
			"https://webbschema.${Preferences.school}.se/"
				"ajax/ajax_resursbokning.jsp?op=boka"
				"&datum=${_formatDate(date)}"
				"&id=$id"
				"&typ=RESURSER_LOKALER"
				"&intervall=$timeIndex"
				"&moment=${Uri.encodeFull(comment)}"
				"&flik=FLIK_$tabId"
		)).trim() == "OK";
	
	Future<List<BookedRoom>> getBookings({DateTime date, String tabId}) async
	{
		// Because the booking list isn't proper HTML, we have to parse it manually
		
		// Get and parse HTML
		final html = parse(await _get(
			"https://webbschema.${Preferences.school}.se/"
				"minaresursbokningar.jsp"
				"?flik=FLIK_$tabId&datum=${_formatDate(date)}"
		));
		
		//                    <html>     <body>      <div>
		final bookingList = html.firstChild.children[1].children
			.firstWhere((child) => child.id == "minabokningar");
		
		final bookings = bookingList.children
			.where((child) => child.id.startsWith("post_"));
		
		if (bookings.isEmpty)
			return null;
		
		return bookings.map((booking)
		{
			/*
			 * text is:
			 * 19-08-24 18:15 - 20:00 een17014, U2-273Avboka
			 * We want to remove the Avboka text and the
			 * spacing for the time we we get:
			 * 19-08-24 18:15-20:00 een17014, U2-273
			 * [0]: Date, [1]: Time span, [3]: Location
			 */
			
			final text = booking.firstChild.text
				.replaceAll("Avboka", "")
				.replaceAll(" - ", "-")
				.replaceAll(',', '')
				.replaceAll(' ', ' '); // Don't ask
			final parts = text.split(' ');
			
			return BookedRoom(
				// To get rid of the post_
				id: booking.id.substring(5),
				// To get YYYY-MM-DD
				date: "20${parts[0]}",
				// Add back the space
				timeSpan: parts[1].replaceAll("-", " - "),
				// [2] is the ID of who booked
				location: parts[3]
			);
		}).toList();
	}
}

/// Represents an already booked room
class BookedRoom
{
	/// ID used to cancel
	final String id;
	
	/// Date of the booking
	final String date;
	
	/// String representing the time span
	final String timeSpan;
	
	/// Location or resource
	final String location;
	
	BookedRoom({this.id, this.date, this.timeSpan, this.location});
	
	ListTile toListTile(void Function() cancelPressed) =>
		ListTile(
			title: Text(location),
			subtitle: Text("$date, $timeSpan"),
			trailing: FlatButton(
				child: Text("CANCEL"),
				onPressed: cancelPressed,
			),
		);
}

/// Represents a single room
class BookingRoom
{
	/// Title, usually room name
	final String title;
	
	/// Subtitle, usually room info
	final String subtitle;
	
	/// Times for booking
	/// (see BookingResponse.times for each index)
	final List<BookingState> states;
	
	/// If all times for the room are booked
	bool isBooked() =>
		states.every((state) => Booking.isBooked(state));
	
	BookingRoom(this.title, this.subtitle, this.states);
	
	@override
	String toString() => "$title ($subtitle): $states";
}

class BookingResponse
{
	/// List of all available times to book as HH:MM
	final List<String> times;
	
	/// All rooms with current state
	final List<BookingRoom> rooms;
	
	BookingResponse(this.times, this.rooms);
}