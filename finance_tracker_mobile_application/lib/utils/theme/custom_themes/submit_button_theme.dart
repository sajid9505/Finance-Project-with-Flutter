import 'package:flutter/material.dart';

class TButtonTheme {
  TButtonTheme._();

  static final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xfff3EBB8E),
          textStyle: const TextStyle(fontSize: 14, color: Colors.white)));
}
