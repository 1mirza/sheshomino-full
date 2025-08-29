import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // وارد کردن Provider
import 'config/theme/app_theme.dart';
import 'data/repositories/user_repository.dart'; // وارد کردن مدیر پروفایل
import 'features/0_auth/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // یک نمونه از مدیر پروفایل می‌سازیم
  final userRepository = UserRepository();
  // اطلاعات کاربر را در ابتدای برنامه بارگذاری می‌کنیم
  await userRepository.loadProfile();

  runApp(
    // مدیر پروفایل را به کل برنامه معرفی می‌کنیم
    ChangeNotifierProvider(
      create: (context) => userRepository,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... (بقیه کد MyApp بدون تغییر)
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      title: 'شیشمینو',
      theme: AppTheme.getTheme(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
