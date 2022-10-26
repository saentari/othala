import 'package:flutter/material.dart';

// Othala brand colors.
const customYellow = Color(0xFFFBD42C);
const customRed = Color(0xFFEB5757);
const customDarkForeground = Color(0xFFFFFFFF);
const customDarkNeutral7 = Color(0xFFB0B0B0);
const customDarkNeutral5 = Color(0xFF787878);
const customDarkNeutral4 = Color(0xFF5C5C5C);
const customDarkNeutral1 = Color(0xFF1A1A1A);
const customDarkBackground = Color(0xFF000000);

const customWhite = Color(0xFFFFFFFF);
const customGrey = Color(0xFF808080);
const customDarkGrey = Color(0xFF191919);
const customBlack = Color(0xFF000000);
const customBlackOverlay = Color(0xCC000000);
const customTransparent = Colors.transparent;

// Dark theme.
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: customDarkBackground,
  primaryColor: customYellow,
  dividerColor: customDarkNeutral4,
  backgroundColor: customDarkBackground,

  // Text.
  fontFamily: 'Rajdhani',
);

// Light theme.
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: customWhite,
  primaryColor: customYellow,
  dividerColor: customDarkNeutral4,
  backgroundColor: customWhite,

  // Text.
  fontFamily: 'Rajdhani',
);
