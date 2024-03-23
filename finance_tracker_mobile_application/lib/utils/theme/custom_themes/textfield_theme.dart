import 'package:flutter/material.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.black,
    suffixIconColor: Colors.black,
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.black),
    border: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(width: 2, color: Colors.grey)),
    enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(width: 2, color: Colors.grey)),
    focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(width: 2, color: Colors.grey)),
  );
}
