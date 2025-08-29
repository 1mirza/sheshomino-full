import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../farsi_content_viewer/word_antonym_game_screen.dart';
import '../farsi_content_viewer/word_family_game_screen.dart';
import '../farsi_content_viewer/word_meaning_game_screen.dart';

class FarsiLessonDetailScreen extends StatelessWidget {
  final Lesson lesson;
  const FarsiLessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    // <<<<< شروع اصلاحات: خواندن نام کاربر از مدیر پروفایل >>>>>
    final userRepo = Provider.of<UserRepository>(context, listen: false);
    final userName = userRepo.userProfile?.name ?? "دانش‌آموز";
    // <<<<< پایان اصلاحات >>>>>

    final List<Map<String, dynamic>> options = [
      {'title': 'معنی کلمات', 'icon': Icons.translate, 'page': 'meaning'},
      {
        'title': 'کلمات هم خانواده',
        'icon': Icons.group_work_outlined,
        'page': 'family'
      },
      {
        'title': 'کلمات متضاد',
        'icon': Icons.compare_arrows_outlined,
        'page': 'antonym'
      },
      {'title': 'کلمات مهم املایی', 'icon': Icons.spellcheck, 'page': null},
      {'title': 'متن درس', 'icon': Icons.article_outlined, 'page': null},
      {'title': 'نگارش', 'icon': Icons.edit_outlined, 'page': null},
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
              onTap: () {
                if (lesson.lessonNumber == null) return;

                if (option['page'] == 'meaning') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordMeaningGameScreen(
                        // <<<<< اصلاح شد: ارسال شماره درس و نام کاربر >>>>>
                        lessonNumber: lesson.lessonNumber!,
                        userName: userName,
                      ),
                    ),
                  );
                } else if (option['page'] == 'family') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordFamilyGameScreen(
                        // <<<<< اصلاح شد: ارسال شماره درس و نام کاربر >>>>>
                        lessonNumber: lesson.lessonNumber!,
                        userName: userName,
                      ),
                    ),
                  );
                } else if (option['page'] == 'antonym') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordAntonymGameScreen(
                        // <<<<< اصلاح شد: ارسال شماره درس و نام کاربر >>>>>
                        lessonNumber: lesson.lessonNumber!,
                        userName: userName,
                      ),
                    ),
                  );
                } else {
                  print('${option['title']} tapped - No page yet.');
                }
              },
            ),
          );
        },
      ),
    );
  }
}
