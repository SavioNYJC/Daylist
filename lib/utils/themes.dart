import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

// App theme
var appTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "DM Sans",
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey.shade100),
    ),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 40,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      letterSpacing: -1,
    ),
    headlineMedium: TextStyle(
      fontSize: 32,
      color: Colors.black,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontSize: 28,
      color: Colors.black,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    bodyMedium: TextStyle(fontSize: 18),
    labelMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
    ),
  ),
);

// Liquid glass themes
var glassCardStyle = LiquidGlassStyle(
  shape: LiquidGlassShape.continuousRoundedRectangle(cornerRadius: 28),
  refractionIndex: 2,
  refractionWidth: 24,
  blur: 3,
  shadow: LiquidGlassShadow(
    blur: 10,
    opacity: 0.25,
    inset: -10,
    cornerRadius: 20,
    offset: Offset(0, 5),
  ),
  // color: Color(0x22FFFFFF),
);

var glassButtonStyle = LiquidGlassStyle(
  shape: LiquidGlassShape.continuousRoundedRectangle(cornerRadius: 28),
  refractionIndex: 2,
  refractionWidth: 24,
  blur: 3,
  shadow: LiquidGlassShadow(
    blur: 10,
    opacity: 0.16,
    inset: -15,
    cornerRadius: 20,
    offset: Offset(0, 5),
  ),
  // color: Color(0x22FFFFFF),
);
