import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color customContainerColor;
  final Color customTextColor;
  final Color customShadowColor;
  final Color customBusScheduleColor;
  final Color customAccentColor;

  CustomColors({
    required this.customContainerColor,
    required this.customTextColor,
    required this.customShadowColor,
    required this.customBusScheduleColor,
    required this.customAccentColor,
  });

  @override
  CustomColors copyWith({
    Color? customContainerColor,
    Color? customTextColor,
    Color? customShadowColor,
    Color? customBusScheduleColor,
    Color? customAccentColor,
  }) {
    return CustomColors(
      customContainerColor: customContainerColor ?? this.customContainerColor,
      customTextColor: customTextColor ?? this.customTextColor,
      customShadowColor: customShadowColor ?? this.customShadowColor,
      customBusScheduleColor:
          customBusScheduleColor ?? this.customBusScheduleColor,
      customAccentColor: customAccentColor ?? this.customAccentColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      customContainerColor:
          Color.lerp(customContainerColor, other.customContainerColor, t)!,
      customTextColor: Color.lerp(customTextColor, other.customTextColor, t)!,
      customShadowColor:
          Color.lerp(customShadowColor, other.customShadowColor, t)!,
      customBusScheduleColor:
          Color.lerp(customBusScheduleColor, other.customBusScheduleColor, t)!,
      customAccentColor:
          Color.lerp(customAccentColor, other.customAccentColor, t)!,
    );
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: Colors.white,
  primaryColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.white,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: GoogleFonts.inter(color: Colors.black),
  ),
  cardColor: Colors.white,
  canvasColor: Colors.white,
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.inter(color: Colors.black),
    bodyMedium: GoogleFonts.inter(color: Colors.black45),
    bodySmall: GoogleFonts.inter(color: Color.fromARGB(255, 114, 114, 114)),
    displayLarge: GoogleFonts.inter(color: Colors.black),
    displayMedium: GoogleFonts.inter(color: Colors.black),
    displaySmall: GoogleFonts.inter(color: Colors.black),
    headlineMedium: GoogleFonts.inter(color: Colors.black),
    headlineSmall: GoogleFonts.inter(color: Colors.black),
    titleLarge: GoogleFonts.inter(color: Color(0xff6A6A6A)),
    titleMedium: GoogleFonts.inter(color: Colors.white),
    titleSmall: GoogleFonts.inter(color: Color(0xff404040)),
    labelLarge: GoogleFonts.inter(color: Color(0xff292929)),
    labelSmall: GoogleFonts.inter(color: Colors.black),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColors(
      customContainerColor: Colors.white,
      customTextColor: Colors.blueGrey[900]!,
      customShadowColor: Color.fromRGBO(51, 51, 51, 0.10),
      customBusScheduleColor: Color.fromARGB(102, 229, 229, 229),
      customAccentColor: Color.fromARGB(255, 240, 91, 37),
    ),
  ],
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: Color(0xff121212),
  primaryColor: Color.fromARGB(255, 16, 16, 16),
  appBarTheme: AppBarTheme(
    color: Color(0xff121212),
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.inter(color: Colors.white),
  ),
  cardColor: Color.fromARGB(255, 48, 48, 48),
  canvasColor: Colors.black,
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.inter(color: Colors.white),
    bodyMedium: GoogleFonts.inter(color: Colors.white54),
    bodySmall: GoogleFonts.inter(color: Color.fromARGB(255, 201, 201, 201)),
    displayLarge: GoogleFonts.inter(color: Colors.white),
    displayMedium: GoogleFonts.inter(color: Colors.white),
    displaySmall: GoogleFonts.inter(color: Colors.white),
    headlineMedium: GoogleFonts.inter(color: Colors.white),
    headlineSmall: GoogleFonts.inter(color: Colors.white),
    titleLarge: GoogleFonts.inter(color: Color.fromARGB(255, 214, 214, 214)),
    titleMedium: GoogleFonts.inter(color: Color.fromARGB(255, 38, 38, 38)),
    titleSmall: GoogleFonts.inter(color: Color.fromARGB(255, 170, 170, 170)),
    labelLarge: GoogleFonts.inter(color: Color.fromARGB(255, 206, 206, 206)),
    labelSmall: GoogleFonts.inter(color: Colors.white),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColors(
      customContainerColor: Color(0xff292929),
      customTextColor: Colors.blueGrey[50]!,
      customShadowColor: Color.fromRGBO(72, 72, 72, 0.259),
      customBusScheduleColor: Color.fromARGB(102, 56, 56, 56),
      customAccentColor: Color.fromARGB(255, 240, 91, 37),
    ),
  ],
);