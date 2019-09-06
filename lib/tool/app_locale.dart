
import 'package:flutter/material.dart';

class AppLocale
{
	final Locale locale;
	
	Map<String, String> get _values =>
		_localizedValues[locale.languageCode];
	
	AppLocale(this.locale);
	
	static AppLocale of(BuildContext context) =>
		Localizations.of(context, AppLocale);
	
	// TODO: Static, because memory
	Map<String, Map<String, String>> _localizedValues =
	{
		"en": {
			//region generic
			"error": "Error",
			"confirm": "Confirm",
			"cancel": "CANCEL",
			"reset": "RESET",
			"are_you_sure": "Are you sure?",
			"no": "NO",
			"yes": "YES",
			"required": "Required",
			//endregion
			//region start_page
			"title_start": "Select School",
			//endregion
			//region main_page
			"title_schedule": "Schedule",
			"title_booking":  "Booking",
			"title_settings": "Settings",
			//endregion
			//region schedule_page
			"week_days": "MON,TUE,WED,THU,FRI,SAT,SUN",
			"months": "Janurary,February,March,April,May,June,July,August,September,October,November,December",
			"none": "(none)",
			"course_code": "Course Code",
			"course_name": "Course Name",
			"signature": "Signature",
			"locations": "Locations",
			"start": "Start",
			"end": "End",
			"last_modified": "Last Modified",
			"connection_failed": "Connection failed, try again later",
			"no_courses": "No courses found, press the search button to add",
			"no_events": "No events found for saved courses",
			"no_events_month": "No events for this month",
			"week": "WEEK",
			"event": "event",
			"events": "events",
			"title_saved_courses": "Saved Courses",
			"no_saved_courses": "No saved courses found",
			"search": "Search",
			"no_search_results": "No results found",
			//endregion
			//region booking_page
			"book": "BOOK",
			"search_error": "Something went wrong while loading available "
				"resources, check your connection and try again",
			"book_confirm": "Are you sure you want to book "
				"{room} at {time}?",
			"resource_booked": "Resource booked",
			"booking_error": "Something went wrong when booking the resource, "
				"maybe you reached your booking limit?",
			"no_resources": "No available resources found that matches "
				"the specified options",
			"booking_available": "available",
			"bookings_available": "available",
			"select_time_span": "Select time span",
			"location": "Location",
			"day": "Day",
			"time": "Time",
			"any_time": "Any",
			"booking_sign_in": "Booking requires you to sign in from "
				"the settings",
			"cancel_resource_confirm": "Are you sure you want to cancel "
				"resource {location} on {date} at {time}?",
			"cancel_resource_error": "There was an error canceling the "
				"selected resource",
			"comment": "Comment",
			"from": "From",
			"to": "To",
			"no_booked_for_location":
				"No booked resources found for the specified location",
			//endregion
			//region settings_page
			"english": "English",
			"swedish": "Swedish",
			"title_general": "General",
			"change_school_title": "Change school",
			"change_school_info": "Currently {name}",
			"dark_theme_title": "Dark theme",
			"dark_theme_info": "Use a dark theme for the app",
			"language_title": "Language",
			"language_info": "Language to use in the app",
			"title_schedule": "Schedule",
			"course_colors_title": "Course colors",
			"course_colors_info":
				"Set different title colors depending on course",
			"week_numbers_title": "Week numbers",
			"week_numbers_info": "Show week numbers",
			"highlight_collisions_title": "Highlight collisions",
			"highlight_collisions_info":
				"Color time when multiple events occur at the same time",
			"today_view_title": "Today view",
			"today_view_info": "Display a subtitle with events for today",
			"title_account": "Account",
			"logged_in_title": "Logged in",
			"logged_out_title": "Logged out",
			"logged_in_info": "You're logged in as {username}",
			"logged_out_info": "You're currently not logged in to your school account",
			"log_in": "Log in",
			"log_out": "Log out",
			"title_about": "About",
			"privacy_policy": "Privacy policy",
			"licenses": "Licenses",
			"whats_new": "What's new"
			//endregion
		},
		"sv": {
			//region generic
			"error": "Fel",
			"confirm": "Bekräfta",
			"cancel": "AVBRYT",
			"reset": "ÅTERSTÄLL",
			"are_you_sure": "Är du säker?",
			"no": "NEJ",
			"yes": "JA",
			"required": "Obligatorisk",
			//endregion
			//region start_page
			"title_start": "Välj Skola",
			//endregion
			//region main_page
			"title_schedule": "Schema",
			"title_booking":  "Bokning",
			"title_settings": "Inställningar",
			//endregion
			//region schedule_page
			"week_days": "MÅN,TIS,ONS,TOR,FRE,LÖR,SÖN",
			"months": "Januari,Februari,Mars,April,Maj,Juni,Juli,Augusti,September,Oktober,November,December",
			"none": "(saknas)",
			"course_code": "Kurskod",
			"course_name": "Kursnamn",
			"signature": "Signatur",
			"locations": "Platser",
			"start": "Start",
			"end": "Slut",
			"last_modified": "Senast Uppdaterad",
			"connection_failed": "Anslutning misslyckades, försök igen senare",
			"no_courses": "Inga kurser hittades, tryck sök för att lägga till",
			"no_events": "Inga händelser hittades för de sparade kurserna",
			"no_events_month": "Inga händelser den här månaden",
			"week": "VECKA",
			"event": "händelse",
			"events": "händelser",
			"title_saved_courses": "Sparade Kurser",
			"no_saved_courses": "Inga sparade kurser hittades",
			"search": "Sök",
			"no_search_results": "Inga resultat hittades",
			//endregion
			//region booking_page
			"book": "BOKA",
			"search_error": "Någet gick fel under laddning av resurser, "
				"kolla din anslutning och försök igen",
			"book_confirm": "Är du säker att du vill boka "
				"{room} till {time}?",
			"resource_booked": "Resurs bokad",
			"booking_error": "Något gick fel när resursen skulle bokas, "
				"har du nått din bokningsbegränsning?",
			"no_resources": "Inga tillgängliga resurser som passar "
				"dina alternativ",
			"booking_available": "ledig",
			"bookings_available": "lediga",
			"select_time_span": "Välj tidsintervall",
			"location": "Plats",
			"day": "Dag",
			"time": "Tid",
			"any_time": "Alla",
			"booking_sign_in": "Bokning kräver att du loggar in från "
				"inställningarna",
			"cancel_resource_confirm": "Är du säker att du vill avboka "
				"resurs {location} på {date} till {time}?",
			"cancel_resource_error": "Något gick fel när resursen "
				"skulle avbokas",
			"comment": "Kommentar",
			"from": "Från",
			"to": "Till",
			"no_booked_for_location": "Inga bokade resurser på valda platsen",
			//endregion
			//region settings_page
			"english": "Engelska",
			"swedish": "Svenska",
			"title_general": "Allmänt",
			"change_school_title": "Byt skola",
			"change_school_info": "Just nu {name}",
			"dark_theme_title": "Mörkt tema",
			"dark_theme_info": "Använd ett mörkt tema för appen",
			"language_title": "Språk",
			"language_info": "Språk att använda i appen",
			"title_schedule": "Schema",
			"course_colors_title": "Kursfärger",
			"course_colors_info": "Färga titlar beroende på kurs",
			"week_numbers_title": "Veckonummer",
			"week_numbers_info": "Visa veckonummer",
			"highlight_collisions_title": "Markera kollisioner",
			"highlight_collisions_info":
				"Färga tider när händelser kolliderar",
			"today_view_title": "Idag",
			"today_view_info": "Visa en undertitel med händelser idag",
			"title_account": "Konto",
			"logged_in_title": "Inloggad",
			"logged_out_title": "Utloggad",
			"logged_in_info": "Inloggad som {username}",
			"logged_out_info": "Du är inte inloggad på ditt skolkonto",
			"log_in": "Logga in",
			"log_out": "Logga ut",
			"title_about": "Om",
			"privacy_policy": "Integritetspolicy",
			"licenses": "Licenser",
			"whats_new": "Vad är nytt"
			//endregion
		}
	};
	
	String get(String value) => _values[value];
}