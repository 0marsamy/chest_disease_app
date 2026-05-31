import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.buttonsAndNav,
  fontFamily: "Poppins",
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.white,
  ),
  buttonTheme: const ButtonThemeData(buttonColor: AppColors.buttonsAndNav),
);

ThemeData appDarkTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF121212),
  primaryColor: AppColors.buttonsAndNav,
  fontFamily: "Poppins",
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
  ),
  buttonTheme: const ButtonThemeData(buttonColor: AppColors.buttonsAndNav),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.buttonsAndNav,
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
  ),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: const Color(0xFF2C2C2C),
);
