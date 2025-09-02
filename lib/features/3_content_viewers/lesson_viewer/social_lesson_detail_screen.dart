import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/user_repository.dart';

class SocialLessonDetailScreen extends StatelessWidget {
  final int chapterNumber;
  final Lesson lesson;

  const SocialLessonDetailScreen({
    super.key,
    required this.chapterNumber,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    // گزینه‌های این بخش را تعریف می‌کنیم
    final List<Map<String, dynamic>> options = [
      {'title': 'جزوه آموزشی', 'icon': Icons.book_outlined},
      {'title': 'فعالیت ها', 'icon': Icons.group_work_outlined},
      {'title': 'آزمون', 'icon': Icons.quiz_outlined},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: ListTile(
              leading:
                  Icon(option['icon'], color: Theme.of(context).primaryColor),
              title: Text(
                option['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              // ***** اصلاحیه اصلی اینجاست *****
              // دکمه همیشه فعال است و یک پیام نمایش می‌دهد
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'این بخش هنوز آماده نشده است. به زودی اضافه خواهد شد!'),
                    backgroundColor: Colors.blueGrey,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
