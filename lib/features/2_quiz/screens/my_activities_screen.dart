import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/quiz_result_model.dart';
import '../../../../data/repositories/user_repository.dart';
import 'quiz_result_screen.dart';

class MyActivitiesScreen extends StatelessWidget {
  const MyActivitiesScreen({super.key});

  // تابعی کمکی برای فرمت کردن تاریخ به شکلی خواناتر
  String _formatDate(DateTime date) {
    // این یک فرمت‌کننده‌ی ساده است. برای فرمت‌های پیچیده‌تر می‌توان از پکیج intl استفاده کرد.
    return "${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فعالیت‌های من'),
      ),
      // از Consumer استفاده می‌کنیم تا به تغییرات UserRepository گوش دهد
      body: Consumer<UserRepository>(
        builder: (context, userRepo, child) {
          // بررسی می‌کنیم که آیا پروفایل کاربر و تاریخچه آزمون‌ها وجود دارد یا خیر
          if (userRepo.userProfile == null ||
              userRepo.userProfile!.quizHistory.isEmpty) {
            return const Center(
              child: Text(
                'شما هنوز در هیچ آزمونی شرکت نکرده‌اید.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // لیست را مرتب‌سازی می‌کنیم تا جدیدترین آزمون‌ها در بالا نمایش داده شوند
          final sortedHistory =
              List<QuizResult>.from(userRepo.userProfile!.quizHistory)
                ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sortedHistory.length,
            itemBuilder: (context, index) {
              final result = sortedHistory[index];
              return Card(
                elevation: 4,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      '${result.score}/${result.totalQuestions}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    '${result.bookTitle} - ${result.lessonTitle}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_formatDate(result.date)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // با کلیک روی هر آیتم، به صفحه‌ی جزئیات نتایج آن آزمون بروید
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizResultScreen(result: result),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
