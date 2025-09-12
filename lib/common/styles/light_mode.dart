import 'package:flutter/material.dart';

// ThemeData lightMode = ThemeData(
//   brightness: Brightness.light,
//   scaffoldBackgroundColor: Colors.grey[100],
//   colorScheme: ColorScheme.light(
//     surface: Colors.grey.shade300,
//     primary: Colors.grey.shade200,
//     secondary: Colors.grey.shade400,
//     inversePrimary: Colors.grey.shade800,
//   ),
//   textTheme: ThemeData.light().textTheme.apply(
//     bodyColor: Colors.grey[800],
//     displayColor: Colors.black,
//   ),
//   appBarTheme: const AppBarTheme(
//     backgroundColor: Colors.white,
//     foregroundColor: Colors.black,
//   ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.black,
//       foregroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     ),
//   ),
//   inputDecorationTheme: const InputDecorationTheme(
//     filled: true,
//     fillColor: Colors.black12,
//     labelStyle: TextStyle(color: Colors.black),
//     hintStyle: TextStyle(color: Colors.grey),
//     border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
//     enabledBorder: UnderlineInputBorder(
//       borderRadius: BorderRadius.all(Radius.circular(5)),
//       // borderSide: BorderSide(color: Colors.black),
//     ),
//     focusedBorder: UnderlineInputBorder(
//       // borderSide: BorderSide(color: Colors.blue),
//     ),
//   ),
//   textSelectionTheme: const TextSelectionThemeData(
//     cursorColor: Colors.black,
//     selectionColor: Colors.black26, // Optional
//     selectionHandleColor: Colors.black, // Optional
//   ),
// );

const Color kAccentTeal = Color(0xFF228886);

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey[100],
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: kAccentTeal, // 🌊 teal accent
    secondary: Colors.grey.shade400,
    inversePrimary: Colors.grey.shade800,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey[800],
    displayColor: Colors.black,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
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
    fillColor: Colors.black12,
    labelStyle: const TextStyle(color: Colors.black),
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: UnderlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      borderSide: BorderSide(color: kAccentTeal),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: kAccentTeal, width: 2),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: kAccentTeal,
    selectionColor: kAccentTeal,
    selectionHandleColor: kAccentTeal,
  ),
);