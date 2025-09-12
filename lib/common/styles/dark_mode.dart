import 'package:flutter/material.dart';

// ThemeData darkMode = ThemeData(
//   brightness: Brightness.dark,
//   scaffoldBackgroundColor: Colors.black,
//   colorScheme: ColorScheme.dark(
//     surface: Colors.grey.shade900,
//     primary: Colors.grey.shade800,
//     secondary: Colors.grey.shade700,
//     inversePrimary: Colors.grey.shade300,
//   ),
//   textTheme: ThemeData.dark().textTheme.apply(
//     bodyColor: Colors.grey[300],
//     displayColor: Colors.white,
//   ),
//   appBarTheme: const AppBarTheme(
//     backgroundColor: Colors.black,
//     foregroundColor: Colors.white,
//   ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     ),
//   ),
//   inputDecorationTheme: const InputDecorationTheme(
//     filled: true,
//     fillColor: Colors.white10,
//     labelStyle: TextStyle(color: Colors.white),
//     hintStyle: TextStyle(color: Colors.grey),
//     border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.all(Radius.circular(5)),
//       borderSide: BorderSide(color: Colors.white),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Colors.blue),
//     ),
//   ),
//   textSelectionTheme: const TextSelectionThemeData(
//     cursorColor: Colors.white,
//     selectionColor: Colors.white24, // Optional
//     selectionHandleColor: Colors.white, // Optional
//   ),
// );

const Color kAccentTeal = Color(0xFF228886);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: kAccentTeal, // 🌊 teal accent
    secondary: Colors.grey.shade700,
    inversePrimary: Colors.grey.shade300,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[300],
    displayColor: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccentTeal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white10,
    labelStyle: const TextStyle(color: Colors.white),
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      borderSide: BorderSide(color: kAccentTeal),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kAccentTeal, width: 2),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: kAccentTeal,
    selectionColor: kAccentTeal,
    selectionHandleColor: kAccentTeal,
  ),
);
