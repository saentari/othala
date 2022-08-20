import 'package:flutter/material.dart';

/// Othala Colors
const kYellowColor = Color(0xFFFBD42C);
const kRedColor = Color(0xFFEB5757);
const kDarkForegroundColor = Color(0xFFFFFFFF);
const kDarkNeutral7Color = Color(0xFFB0B0B0);
const kDarkNeutral5Color = Color(0xFF787878);
const kDarkNeutral4Color = Color(0xFF5C5C5C);
const kDarkNeutral1Color = Color(0xFF1A1A1A);
const kDarkBackgroundColor = Color(0xFF000000);

const kWhiteColor = Color(0xFFFFFFFF);
const kGreyColor = Color(0xFF808080);
const kDarkGreyColor = Color(0xFF191919);
const kBlackColor = Color(0xFF000000);
const kBlackOverlayColor = Color(0xCC000000);
const kTransparentColor = Colors.transparent;

/// Dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kDarkBackgroundColor,
  primaryColor: kYellowColor,
  dividerColor: kDarkNeutral4Color,
  backgroundColor: kDarkBackgroundColor,

  // Text
  fontFamily: 'Rajdhani',
);

/// Light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: kWhiteColor,
  primaryColor: kYellowColor,
  dividerColor: kDarkNeutral4Color,
  backgroundColor: kWhiteColor,

  // Text
  fontFamily: 'Rajdhani',
);
