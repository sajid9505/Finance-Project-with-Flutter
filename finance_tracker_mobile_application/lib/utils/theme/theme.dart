import 'package:finance_tracker_mobile_application/utils/theme/custom_themes/accent_button_theme.dart';
import 'package:finance_tracker_mobile_application/utils/theme/custom_themes/submit_button_theme.dart';
import 'package:finance_tracker_mobile_application/utils/theme/custom_themes/chip_theme.dart';
import 'package:finance_tracker_mobile_application/utils/theme/custom_themes/text_theme.dart';
import 'package:finance_tracker_mobile_application/utils/theme/custom_themes/textfield_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData theme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      primaryColor: const Color(0xfff3EBB8E),
      textTheme: TTextTheme.textTheme,
      elevatedButtonTheme: TButtonTheme.elevatedButtonTheme,
      inputDecorationTheme: TTextFormFieldTheme.inputDecorationTheme,
      chipTheme: TChipTheme.chipTheme,
      buttonTheme: TAccentButtonTheme.accentButtonTheme
  );
}


// Themes left to add:
// Cards
// Tabs
// Modals
// Buttons