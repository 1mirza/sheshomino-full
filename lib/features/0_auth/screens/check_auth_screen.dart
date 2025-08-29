import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../1_home/screens/home_screen.dart'; // مسیر صفحه اصلی جدید
import 'registration_screen.dart'; // مسیر صفحه ثبت نام

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkIfRegistered();
  }

  Future<void> _checkIfRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userName = prefs.getString('user_name');

    // این یک تاخیر کوچک است تا انیمیشن انتقال صفحه بهتر دیده شود
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      if (userName != null && userName.isNotEmpty) {
        // اگر کاربر قبلا ثبت‌نام کرده، به صفحه اصلی برو
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(name: userName)),
        );
      } else {
        // در غیر این صورت، به صفحه ثبت‌نام برو
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // یک صفحه لودینگ ساده تا زمانی که وضعیت کاربر بررسی می‌شود
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
