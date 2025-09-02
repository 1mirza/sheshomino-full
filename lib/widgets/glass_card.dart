import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin; // **پارامتر جدید اضافه شد**
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin, // **پارامتر جدید اضافه شد**
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // **اصلاح شد: از پارامتر مارجین استفاده می‌کنیم**
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
