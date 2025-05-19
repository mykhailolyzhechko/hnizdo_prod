import 'package:flutter/material.dart';

// Define missing color variables
final Color primaryColor = Color(0xFFA366D0);
final Color viewLineColor = Color(0xFFEAEAEA);
final Color cardLightColor = Colors.white;
final Color scaffoldColorDark = Color(0xFF121212);
final Color cardDarkColor = Color(0xFF1E1E1E);

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent),
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryColor,
    iconTheme: IconThemeData(color: Colors.black),
    dividerColor: viewLineColor,
    cardColor: cardLightColor,
    colorScheme: ColorScheme(
      primary: primaryColor,
      secondary: Color(0xFF6C63FF), // Slightly different secondary color for better contrast
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.redAccent,
      brightness: Brightness.light,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(width: 1, color: primaryColor),
      ),
      checkColor: MaterialStateProperty.all(Colors.white),
      fillColor: MaterialStateProperty.all(primaryColor),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent),
    scaffoldBackgroundColor: scaffoldColorDark,
    iconTheme: IconThemeData(color: Colors.white),
    cardColor: cardDarkColor,
    colorScheme: ColorScheme(
      primary: primaryColor,
      secondary: Color(0xFF9A8CFF), // Softer secondary color for dark mode
      surface: Colors.black,
      background: Colors.black,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.redAccent,
      brightness: Brightness.dark,
    ),
    dividerColor: Colors.white24,
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white70),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(width: 1, color: primaryColor),
      ),
      checkColor: MaterialStateProperty.all(Colors.white),
      fillColor: MaterialStateProperty.all(primaryColor),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
