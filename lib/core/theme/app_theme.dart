import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      textTheme: GoogleFonts.interTextTheme(),
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      useMaterial3: true,
    );
  }
}
