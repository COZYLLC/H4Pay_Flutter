import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    surface: Colors.yellow,
    onSurface: Colors.black,
    // Colors that are not relevant to AppBar in DARK mode:
    primary: Colors.grey,
    onPrimary: Colors.grey,
    primaryVariant: Colors.grey,
    secondary: Colors.grey,
    secondaryVariant: Colors.grey,
    onSecondary: Colors.grey,
    background: Colors.grey,
    onBackground: Colors.grey,
    error: Colors.grey,
    onError: Colors.grey,
  ),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    surface: Colors.yellow,
    onSurface: Colors.black,
    // Colors that are not relevant to AppBar in DARK mode:
    primary: Colors.grey,
    onPrimary: Colors.grey,
    primaryVariant: Colors.grey,
    secondary: Colors.grey,
    secondaryVariant: Colors.grey,
    onSecondary: Colors.grey,
    background: Colors.grey,
    onBackground: Colors.grey,
    error: Colors.grey,
    onError: Colors.grey,
  ),
);
