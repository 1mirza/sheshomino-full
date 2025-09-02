import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor:
          Colors.transparent, // مهم: برای نمایش گرادینت پس‌زمینه
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.purple,
      ).copyWith(
        secondary: AppColors.accent,
      ),

      // تم AppBar با افکت شیشه‌ای
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.glassFill.withOpacity(0.5), // نیمه‌شفاف
        elevation: 0, // حذف سایه
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Vazir',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // تم کارت‌ها برای داشتن ظاهر شیشه‌ای
      // نکته: این تم یک ظاهر پایه می‌دهد و افکت اصلی در ویجت GlassCard اعمال می‌شود
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.glassBorder, // حاشیه سفید نیمه‌شفاف
            width: 1.5,
          ),
        ),
        color: AppColors.glassFill, // رنگ نیمه‌شفاف شیشه‌ای
        clipBehavior: Clip.antiAlias, // برای گرد شدن گوشه‌ها
      ),

      // تم دکمه‌ها با ظاهر مدرن و گرادینت
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return AppColors.primary.withOpacity(0.8);
              }
              return AppColors.primary;
            },
          ),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) return 2.0;
            return 8.0;
          }),
          shadowColor: MaterialStateProperty.all<Color>(
              AppColors.primary.withOpacity(0.5)),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              fontFamily: 'Vazir',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // فونت پیش‌فرض
      fontFamily: 'Vazir',

      // تم متن
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textSecondary, height: 1.5),
        titleLarge: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
