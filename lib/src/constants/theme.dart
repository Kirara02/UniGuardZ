import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:ugz_app/src/constants/colors.dart';

class AppTheme {
  static final lightTheme = FlexThemeData.light(
    fontFamily: "Poppins",
    scheme: FlexScheme.aquaBlue,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ).copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static final darkTheme = FlexThemeData.dark(
    fontFamily: "Poppins",
    scheme: FlexScheme.deepBlue,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3ErrorColors: true,
  ).copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
