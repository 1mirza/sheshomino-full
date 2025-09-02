import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    // --- شروع تغییرات نهایی ---
    // این کد ظاهر کارت‌ها را دقیقاً مطابق با درخواست شما می‌کند:
    // پس‌زمینه سفید مات برای خوانایی بالا و حاشیه رنگی زیبا.
    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // پس‌زمینه کاملاً سفید و مات
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5), // حاشیه رنگی با شفافیت کم
          width: 2.0, // ضخامت حاشیه
        ),
        boxShadow: [
          // یک سایه بسیار ملایم برای برجستگی و زیبایی بیشتر
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
    // --- پایان تغییرات نهایی ---
  }
}
