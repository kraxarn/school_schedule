
class DateFormatter
{
	/// Adds a leading zero if < 10
	static String addLeading(int value) =>
		value < 10 ? "0$value" : "$value";
	
	/// Formats as YYYY-MM-DD
	static String asFullDate(DateTime date) =>
		"${date.year}-${addLeading(date.month)}-${addLeading(date.day)}";
	
	/// Formats as HH:MM
	static String asTime(DateTime date) =>
		"${addLeading(date.hour)}:${addLeading(date.minute)}";
	
	/// Formats as YYYY-MM-DD HH:MM
	static String asFullDateTime(DateTime date) =>
		"${asFullDate(date)} ${asTime(date)}";
}