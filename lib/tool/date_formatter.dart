
class DateFormatter
{
	/// Adds a leading zero if < 10
	static String addLeading(int value) =>
		value < 10 ? "0$value" : "$value";
	
	/// First day of the year of the date
	static DateTime startOfYear(DateTime date) =>
		DateTime(date.year);
	
	/// Formats as YYYY-MM-DD
	static String asFullDate(DateTime date) =>
		"${date.year}-${addLeading(date.month)}-${addLeading(date.day)}";
	
	/// Formats as HH:MM
	static String asTime(DateTime date) =>
		"${addLeading(date.hour)}:${addLeading(date.minute)}";
	
	/// Formats as YYYY-MM-DD HH:MM
	static String asFullDateTime(DateTime date) =>
		"${asFullDate(date)} ${asTime(date)}";
	
	/// Gets the week number for the specific date
	static int getWeekNumber(DateTime date) =>
		((date.difference(startOfYear(date)).inDays / 7.0).floor() % 52) + 1;
}