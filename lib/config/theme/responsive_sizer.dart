import 'package:flutter/material.dart';

class ResponsiveSizer {
  static late double _screenWidth;
  static late double _screenHeight;

  // این متد باید در ابتدای هر صفحه فراخوانی شود
  static void init(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }

  // تابعی برای محاسبه اندازه فونت بر اساس عرض صفحه
  // sp مخفف Scale-independent Pixels است
  static double sp(double fontSize) {
    // عرض مرجع ما، عرض یک گوشی متوسط است (مثلاً 375 پیکسل)
    // اگر صفحه بزرگتر باشد، فونت کمی بزرگتر و اگر کوچکتر باشد، کمی کوچکتر می‌شود.
    return fontSize * (_screenWidth / 375.0);
  }

  // تابعی برای محاسبه اندازه ویجت‌ها بر اساس عرض صفحه
  static double width(double percent) {
    return _screenWidth * (percent / 100);
  }

  // تابعی برای محاسبه اندازه ویجت‌ها بر اساس ارتفاع صفحه
  static double height(double percent) {
    return _screenHeight * (percent / 100);
  }
}
