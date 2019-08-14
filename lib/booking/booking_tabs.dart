
class BookingTabs
{
	// TODO: This is for now hard coded
	
	static Map<String, String> get(String schoolId)
	{
		switch (schoolId)
		{
			// hb
			case "hb": return {
				"0008": "Allmänna grupprum",
				"0009": "Bibliotekets grupprum plan 5",
				"0010": "Bibliotekets grupprum plan 3"
			};
			// hig
			// hv
			// konstfack
			// ltu
			// mau
			// mdh
			case "mdh": return {
				"0000": "Eskilstuna",
				"0001": "Västerås",
				"0005": "Kammarmusiken Slottet"
			};
			// slu
			// sh
			// oru
			default: return null;
		}
	}
}