
class DateFormatter
{
	/// Adds a leading zero if < 10
	static String _addLeading(int value) =>
		value < 10 ? "0$value" : "$value";
	
	/// Formats as YYYY-MM-DD
	static String asFullDate(DateTime date) =>
		"${date.year}-${_addLeading(date.month)}-${_addLeading(date.day)}";
	
	/// Formats as YYYY-MM-DD HH:MM
	static String asFullDateTime(DateTime date) =>
		"${asFullDate(date)} "
			"${_addLeading(date.hour)}:${_addLeading(date.minute)}";
}