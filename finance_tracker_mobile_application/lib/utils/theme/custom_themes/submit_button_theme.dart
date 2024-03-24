import 'package:flutter/material.dart';

class TButtonTheme {
  TButtonTheme._();

  static final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xfff3EBB8E),
          textStyle: const TextStyle(fontSize: 14, color: Colors.white)));

  static final outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xfff3EBB8E),
      side: const BorderSide(
        color: Color(0xffE8E9ED),
        width: 2,
      ),
      textStyle: const TextStyle(fontSize: 14, color: Color(0xfff3EBB8E)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}
