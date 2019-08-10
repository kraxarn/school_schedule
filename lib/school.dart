
class School
{
	/// All schools as <id, name>
	static var _schools = {
		"hb":        "University of Borås",
		"hig":       "Kristianstad University",
		"hv":        "Högskolan Väst",
		"konstfack": "University College of Arts, Craft and Design",
		"ltu":       "Luleå university of technology",
		"mau":       "Malmö University",
		"mdh":       "Mälardalen University",
		"slu":       "Swedish University of Agricultural Sciences",
		"sh":        "Södertörns university",
		"oru":       "Örebro university",
		null:        "KronoX Demo"
	};
	
	/// Index for the currently selected school
	MapEntry<String, String> _school;
	
	/// All schools as <id, name>
	static Map<String, String> get allSchools => _schools;
	
	/// Get the school ID
	String get id => _school.key;
	
	/// Get the full school name
	String get name => _school.value;
	
	/// Main constructor from the school ID
	School(String schoolId)
	{
		_school = _schools.entries.where((element) {
			return element.key == schoolId;
		}).first;
	}
}