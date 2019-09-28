

import 'package:flutter/material.dart';

import '../tool/preferences.dart';
import 'course_settings.dart';

class UserColor
{
	/// Base color
	final MaterialColor _color;
	
	/// Index for light color
	/// (dark is light -100)
	final int _lightIndex;
	
	/// Color to use for the light theme
	Color get lightColor => _color[_lightIndex];
	
	/// Color to use for the dark theme
	/// (slightly brighter than the base light theme)
	Color get darkColor => _color[_lightIndex - 100];
	
	/// Automatically return dark or light color
	Color get color => Preferences.darkMode ? darkColor : lightColor;
	
	/// Base 500 color
	Color get baseColor => _color[500];
	
	UserColor(this._color, this._lightIndex);
	
	static UserColor fromName(String name) =>
		UserColors().colors.firstWhere((color) => color.toString() == name);
	
	int toIndex()
	{
		// Switch doesn't work here
		if (_color == Colors.red)        return 0;
		if (_color == Colors.pink)       return 1;
		if (_color == Colors.purple)     return 2;
		if (_color == Colors.deepPurple) return 3;
		if (_color == Colors.indigo)     return 4;
		if (_color == Colors.blue)       return 5;
		if (_color == Colors.lightBlue)  return 6;
		if (_color == Colors.cyan)       return 7;
		if (_color == Colors.teal)       return 8;
		if (_color == Colors.green)      return 9;
		if (_color == Colors.lightGreen) return 10;
		if (_color == Colors.lime)       return 11;
		if (_color == Colors.orange)     return 12;
		if (_color == Colors.deepOrange) return 13;
		if (_color == Colors.blueGrey)   return 14;
		return 0;
	}
	
	@override
	String toString() =>
		Preferences.localized("colors").split(',')[toIndex()];
}

class UserColors
{
	final colors = <UserColor>
	[
		// 0: red
		UserColor(Colors.red, 700),
		// 1: pink
		UserColor(Colors.pink, 600),
		// 2: purple
		UserColor(Colors.purple, 400),
		// 3: deepPurple
		UserColor(Colors.deepPurple, 400),
		// 4: indigo
		UserColor(Colors.indigo, 400),
		// 5: blue
		UserColor(Colors.blue, 700),
		// 6: lightBlue
		UserColor(Colors.lightBlue, 800),
		// 7: cyan
		UserColor(Colors.cyan, 800),
		// 8: teal
		UserColor(Colors.teal, 700),
		// 9: green
		UserColor(Colors.green, 800),
		// a: lightGreen
		UserColor(Colors.lightGreen, 900),
		// b: lime
		UserColor(Colors.lime, 900),
		// c: yellow
		// TODO: Yellow doesn't work on light theme
		//UserColor(Colors.yellow, 600),
		// d: amber
		// TODO: Amber doesn't work on light theme either
		//UserColor(Colors.amber, 600),
		// e: orange
		// TODO: Orange doesn't work that well on light theme
		UserColor(Colors.orange, 800),
		// f: deepOrange
		UserColor(Colors.deepOrange, 900),
		// 10: blueGrey
		UserColor(Colors.blueGrey, 600)
	];
	
	UserColor getColor(String name)
	{
		// Try to find saved color and return it
		final settings = CourseSettings.get(name);
		if (settings?.color != null)
			return UserColors().colors[settings.color];
		
		// Default color for name
		return colors[CourseSettings.getId(name).hashCode % colors.length];
	}
}