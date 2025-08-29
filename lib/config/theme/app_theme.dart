import 'package:flutter/material.dart';
import 'app_colors.dart'; // فایل رنگ‌ها را وارد می‌کنیم

class AppTheme {
  // یک متد استاتیک که تم برنامه را برمی‌گرداند
  static ThemeData getTheme() {
    return ThemeData(
      //---------- رنگ‌های اصلی ----------
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.teal,
      ).copyWith(
        secondary: AppColors.accent,
      ),

      //---------- تم AppBar ----------
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazir', // فونت دلخواه
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      //---------- تم دکمه‌ها ----------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      //---------- تم کارت‌ها ----------
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: AppColors.cardBackground,
      ),

      //---------- فونت پیش‌فرض ----------
      fontFamily: 'Vazir',
    );
  }
}
