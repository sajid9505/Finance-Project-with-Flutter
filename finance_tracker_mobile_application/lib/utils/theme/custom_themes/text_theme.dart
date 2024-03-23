import 'package:flutter/material.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme textTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
        fontSize: 36.0, color: Colors.black, fontWeight: FontWeight.normal),
    headlineMedium: const TextStyle().copyWith(
        fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
    headlineSmall: const TextStyle().copyWith(
        fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.normal),
    bodyLarge: const TextStyle().copyWith(
        fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.normal),
    bodyMedium: const TextStyle().copyWith(
        fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.normal),
    bodySmall: const TextStyle().copyWith(
        fontSize: 11.0, color: Colors.black, fontWeight: FontWeight.normal),
    labelLarge: const TextStyle().copyWith(
        fontSize: 14.0,
        color: const Color(0xfff646464),
        fontWeight: FontWeight.normal),
    labelMedium: const TextStyle().copyWith(
        fontSize: 12.0,
        color: const Color(0xfff646464),
        fontWeight: FontWeight.normal),
    labelSmall: const TextStyle().copyWith(
        fontSize: 11.0,
        color: const Color(0xfff646464),
        fontWeight: FontWeight.normal),
    displayLarge: const TextStyle().copyWith(
        fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.normal),
    titleLarge: const TextStyle().copyWith(
        fontSize: 20.0,
        color: const Color(0xfff3EBB8E),
        fontWeight: FontWeight.normal),
    titleMedium: const TextStyle().copyWith(
        fontSize: 16.0,
        color: const Color(0xfff48464E),
        fontWeight: FontWeight.bold),
  );
}
