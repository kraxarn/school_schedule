
import 'package:flutter/material.dart';

class AppLocale
{
	final Locale locale;
	
	Map<String, String> get _values =>
		_localizedValues[locale.languageCode];
	
	AppLocale(this.locale);
	
	static AppLocale of(BuildContext context) =>
		Localizations.of(context, AppLocale);
	
	static const Map<String, Map<String, String>> _localizedValues =
	{
		"en": {
			//region generic
			"error": "Error",
			"confirm": "Confirm",
			"cancel": "CANCEL",
			"reset": "RESET",
			"no": "NO",
			"yes": "YES",
			"required": "Required",
			"delete": "Delete?",
			"default": "Default",
			"something_went_wrong": "Sorry, something went wrong :(",
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
			"months": "January,February,March,April,May,June,July,August,September,October,November,December",
			"none": "(none)",
			"course_code": "Course Code",
			"course_name": "Course Name",
			"signature": "Signature",
			"locations": "Locations",
			"date_time": "Date and time",
			"last_modified": "Last Modified",
			"icon": "Icon",
			"connection_failed": "Connection failed, try again later",
			"no_courses": "No courses found, press the search button to add",
			"no_events": "No events found for saved courses",
			"no_events_filter": "No events found for selected filter options",
			"no_events_month": "No events for this month",
			"no_events_course": "No events for this course",
			"week": "WEEK",
			"event": "event",
			"events": "events",
			"title_saved_courses": "Saved Courses",
			"no_saved_courses": "No saved courses found",
			"search": "Search",
			"no_search_results": "No results found",
			"time_was_ago": "was {time} ago",
			"time_in": "in {time}",
			"time_now": "now",
			"hiding_event": "Hiding {events} duplicate event",
			"hiding_events": "Hiding {events} duplicate events",
			"icon_clear": "Clear",
			"icon_done": "Done",
			"icon_favorite": "Favorite",
			"icon_flag": "Flag",
			"event_duration": "{h}h, {m}m",
			//endregion
			//region course_list_dialog
			"select_color": "Select color",
			"colors": "Red,Pink,Purple,Deep purple,Indigo,Blue,Light blue,Cyan,"
				"Teal,Green,Light green,Lime,Orange,Deep orange,Blue grey",
			"delete_course": "Are you sure you want to delete {code} ({name})?",
			"option_color": "Color...",
			"option_delete": "Delete...",
			"option_list": "Events...",
			"events_for": "Events for {course}",
			//endregion
			//region booking_page
			"book": "BOOK",
			"cancel_booking": "CANCEL",
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
			"cancel_question": "Cancel?",
			"cancel_resource_confirm": "Are you sure you want to cancel "
				"resource {location} on {date} at {time}?",
			"cancel_resource_error": "There was an error canceling the "
				"selected resource",
			"comment": "Comment",
			"from": "From",
			"to": "To",
			"no_booked_for_location":
				"No booked resources found for the specified location",
			"how_to_help": "How to help",
			//endregion
			//region settings_page
			"english": "English",
			"swedish": "Swedish",
			"title_general": "General",
			"change_school_title": "Change school",
			"change_school_info": "Currently {name}",
			"change_question": "Change?",
			"change_school_warning":
				"Changing school removes your login and saved courses, "
					"are you sure you want to change school?",
			"dark_theme_title": "Dark theme",
			"dark_theme_info": "Use a dark theme for the app",
			"restart_app": "Restart app to apply changes",
			"language_title": "Language",
			"language_info": "Language to use in the app",
			"week_numbers_title": "Week numbers",
			"week_numbers_info": "Show week numbers",
			"highlight_collisions_title": "Highlight collisions",
			"highlight_collisions_info":
				"Color time when multiple events occur at the same time",
			"hide_duplicates_title": "Hide duplicates",
			"hide_duplicates_info": "Don't show duplicate events",
			"hide_past_events_title": "Hide past events",
			"hide_past_events_info": "Never show events that has already ended",
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
			"whats_new": "What's new",
			//endregion
			//region login_dialog
			"login_failed": "Login failed",
			"incorrect_login": "Incorrect username or password",
			"title_login": "School login",
			"username": "Username",
			"enter_username": "Please enter username",
			"password": "Password",
			"enter_password": "Please enter password",
			"login": "LOGIN"
			//endregion
		},
		"sv": {
			//region generic
			"error": "Fel",
			"confirm": "Bekräfta",
			"cancel": "AVBRYT",
			"reset": "ÅTERSTÄLL",
			"no": "NEJ",
			"yes": "JA",
			"required": "Obligatorisk",
			"delete": "Radera?",
			"default": "Standard",
			"something_went_wrong": "Tyvärr gick något fel :(",
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
			"date_time": "Dag och tid",
			"last_modified": "Senast Uppdaterad",
			"icon": "Ikon",
			"connection_failed": "Anslutning misslyckades, försök igen senare",
			"no_courses": "Inga kurser hittades, tryck sök för att lägga till",
			"no_events": "Inga händelser hittades för de sparade kurserna",
			"no_events_filter": "Inga händelser hittades för de valda filteralternativen",
			"no_events_month": "Inga händelser den här månaden",
			"no_events_course": "Inga händelser för den kursen",
			"week": "VECKA",
			"event": "händelse",
			"events": "händelser",
			"title_saved_courses": "Sparade Kurser",
			"no_saved_courses": "Inga sparade kurser hittades",
			"search": "Sök",
			"no_search_results": "Inga resultat hittades",
			"time_was_ago": "var {time} sedan",
			"time_in": "om {time}",
			"time_now": "nu",
			"days": "dagar",
			"hour": "timme",
			"hours": "timmar",
			"hiding_event": "Döljer {events} duplicerade händelse",
			"hiding_events": "Döljer {events} duplicerade händelser",
			"icon_clear": "Rensa",
			"icon_done": "Klar",
			"icon_favorite": "Favorit",
			"icon_flag": "Flagga",
			"event_duration": "{h}t, {m}m",
			//endregion
			//region course_list_dialog
			"select_color": "Välj färg",
			"colors": "Röd,Rosa,Lila,Mörklila,Indigo,Blå,Ljusblå,Turkos,"
				"Blågrön,Grön,Ljusgrön,Lime,Orange,Mörkorange,Blågrå",
			"delete_course": "Är du säker på att du vill radera {code} ({name})?",
			"option_color": "Färg...",
			"option_delete": "Radera...",
			"option_list": "Händelser...",
			"events_for": "Händelser för {course}",
			//endregion
			//region booking_page
			"book": "BOKA",
			"cancel_booking": "AVBOKA",
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
			"cancel_question": "Avboka?",
			"cancel_resource_confirm": "Är du säker att du vill avboka "
				"resurs {location} på {date} till {time}?",
			"cancel_resource_error": "Något gick fel när resursen "
				"skulle avbokas",
			"comment": "Kommentar",
			"from": "Från",
			"to": "Till",
			"no_booked_for_location": "Inga bokade resurser på valda platsen",
			"how_to_help": "Hur du kan hjälpa",
			//endregion
			//region settings_pag
			"english": "Engelska",
			"swedish": "Svenska",
			"title_general": "Allmänt",
			"change_school_title": "Byt skola",
			"change_school_info": "Just nu {name}",
			"change_question": "Byta?",
			"change_school_warning":
				"När du byter skola tas din inloggning och sparade kurser bort, "
					"är du säker att du vill byta skola?",
			"dark_theme_title": "Mörkt tema",
			"dark_theme_info": "Använd ett mörkt tema för appen",
			"restart_app": "Starta om appen för att tillämpa ändringarna",
			"language_title": "Språk",
			"language_info": "Språk att använda i appen",
			"week_numbers_title": "Veckonummer",
			"week_numbers_info": "Visa veckonummer",
			"highlight_collisions_title": "Markera kollisioner",
			"highlight_collisions_info":
				"Färga tider när händelser kolliderar",
			"hide_duplicates_title": "Dölj dupletter",
			"hide_duplicates_info": "Visa inte duplicerade händelser",
			"hide_past_events_title": "Dölj tidigare händelser",
			"hide_past_events_info": "Visa aldrig händelser som redan slutat",
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
			"whats_new": "Vad är nytt",
			//endregion
			//region login_dialog
			"login_failed": "Inloggning misslyckades",
			"incorrect_login": "Fel användarnamn eller lösenord",
			"title_login": "Skolinloggning",
			"username": "Användarnamn",
			"enter_username": "Var god ange användarnamn",
			"password": "Lösenord",
			"enter_password": "Var god ange lösenord",
			"login": "LOGGA IN"
			//endregion
		}
	};
	
	String get(String value) => _values[value] ?? value;
}