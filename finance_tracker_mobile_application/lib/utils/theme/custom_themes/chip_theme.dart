import 'package:flutter/material.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData chipTheme = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(0.4),
    labelStyle: const TextStyle(color: Color(0xfff49454F)),
    selectedColor:  const Color(0xfff3EBB8E),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: Colors.white,
  ); // ChipThemeData
}
