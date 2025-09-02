import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'data/repositories/activity_repository.dart';
import 'data/repositories/user_repository.dart';
import 'features/0_auth/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userRepository = UserRepository();
  await userRepository.loadProfile();

  // ساخت یک نمونه از ریپازیتوری فعالیت‌ها
  final activityRepository = ActivityRepository();

  runApp(
    // استفاده از MultiProvider برای معرفی هر دو ریپازیتوری به برنامه
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userRepository),
        ChangeNotifierProvider(create: (context) => activityRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
