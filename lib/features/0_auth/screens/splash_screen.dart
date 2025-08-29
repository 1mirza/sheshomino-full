import 'dart:async';
import 'package:flutter/material.dart';
import 'check_auth_screen.dart'; // برای هدایت به صفحه بررسی ورود

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // تایمر برای انتقال خودکار بعد از 5 ثانیه
    Timer(const Duration(seconds: 5), () {
      // استفاده از pushReplacement تا کاربر نتواند با دکمه بازگشت به این صفحه برگردد
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CheckAuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // استفاده از Scaffold برای داشتن یک پس‌زمینه استاندارد
    return Scaffold(
      // می‌توانید رنگ پس‌زمینه را با تم برنامه هماهنگ کنید
      // backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ۱. لوگوی برنامه
            // مطمئن شوید که یک تصویر به نام logo.png در پوشه assets/images/ دارید
            Image.asset('assets/images/logo.png', width: 150, height: 150),
            const SizedBox(height: 24),

            // ۲. جمله انگیزشی
            const Text(
              'وقتی بازی می‌کنی، یادگیری ماجراجویی می‌شه!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal, // می‌توانید این رنگ را تغییر دهید
              ),
            ),
            const SizedBox(height: 40),

            // ۳. انیمیشن لودینگ
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
