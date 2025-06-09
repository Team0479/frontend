import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'PixeloidSans',
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black),
        titleTextStyle: TextStyle(
          fontFamily: 'Spoqa Han Sans Neo',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'PixeloidSans',
          fontFamilyFallback: ['DungGeunMo'],
          fontSize: 16,
          color: AppColors.text,
        ),
        titleLarge: TextStyle(
          fontFamily: '8bitWonder',
          fontFamilyFallback: ['DungGeunMo'],
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
        labelLarge: TextStyle(
          fontFamily: 'PixeloidSans',
          fontFamilyFallback: ['DungGeunMo'],
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Galmuri14',
          fontSize: 13,
          color: AppColors.textSub,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.disabled,
          foregroundColor: AppColors.textSub,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: AppTextStyles.caption,
        labelStyle: AppTextStyles.body,
      ),
      cardTheme: CardTheme(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.appBarBlue,
        unselectedItemColor: AppColors.textSub,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Navigation Icons
class NavIcons {
  static const String home = 'assets/images/nav_home.png';
  static const String homeUnselected = 'assets/images/nav_home_unselected.png';
  static const String calendar = 'assets/images/nav_calendar.png';
  static const String calendarUnselected = 'assets/images/nav_calendar_unselected.png';
  static const String inventory = 'assets/images/nav_inventory.png';
  static const String inventoryUnselected = 'assets/images/nav_inventory_unselected.png';
  static const String square = 'assets/images/nav_square.png';
  static const String squareUnselected = 'assets/images/nav_square_unselected.png';
} 