import 'package:flutter/material.dart';

// این کلاس تمام رنگ‌های مورد استفاده در تم شیشه‌ای جدید و شاد را نگهداری می‌کند
class AppColors {
  // --- پالت رنگی جدید، شاداب و با کنتراست بالا ---

  // رنگ‌های اصلی تم (نارنجی پرانرژی و آبی آسمانی)
  static const Color primary = Color(0xFFFF7043); // Coral Orange
  static const Color accent = Color(0xFF4FC3F7); // Bright Sky Blue

  // گرادینت پس‌زمینه بسیار روشن، ملایم و شاد (زرد کم‌رنگ به آبی آسمانی)
  static const Color backgroundStart = Color(0xFFFFF9C4); // Very Light Yellow
  static const Color backgroundEnd = Color(0xFFE0F7FA); // Very Light Cyan

  // رنگ‌های مخصوص افکت شیشه‌ای با شفافیت کمتر برای روشنایی بیشتر
  // این تغییر مستقیماً مشکل تیرگی داخل اسلایدها را حل می‌کند
  static const Color glassFill =
      Color.fromRGBO(255, 255, 255, 0.7); // روشن‌تر و واضح‌تر
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.8);

  // رنگ‌های متن با کنتراست بالا برای خوانایی عالی
  static const Color textPrimary = Color(0xFF455A64); // Dark Blue Grey
  static const Color textSecondary = Color(0xFF607D8B); // Lighter Blue Grey

  // رنگ‌های استاندارد
  static const Color success = Color(0xFF00C853); // Green
  static const Color error = Color(0xFFD50000); // Red
  static const Color coin = Colors.amber;
}
