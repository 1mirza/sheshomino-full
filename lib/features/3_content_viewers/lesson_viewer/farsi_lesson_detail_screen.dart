import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../farsi_content_viewer/word_antonym_game_screen.dart';
import '../farsi_content_viewer/word_family_game_screen.dart';
import '../farsi_content_viewer/word_meaning_game_screen.dart';
import '../farsi_content_viewer/word_spelling_game_screen.dart';
// <<<<< اصلاحیه: فایل‌های بازی جدید در اینجا اضافه شدند >>>>>
import '../farsi_content_viewer/text_lesson_game_screen.dart';
import '../farsi_content_viewer/negaresh_game_screen.dart';

class FarsiLessonDetailScreen extends StatelessWidget {
  final Lesson lesson;
  const FarsiLessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final userRepo = Provider.of<UserRepository>(context, listen: false);
    final userName = userRepo.userProfile?.name ?? "دانش‌آموز";

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
      {
        'title': 'کلمات مهم املایی',
        'icon': Icons.spellcheck,
        'page': 'spelling'
      },
      {
        'title': 'متن درس',
        'icon': Icons.article_outlined,
        'page': 'text_lesson'
      },
      {'title': 'نگارش', 'icon': Icons.edit_outlined, 'page': 'negaresh'},
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

                Widget? destination;
                switch (option['page']) {
                  case 'meaning':
                    destination = WordMeaningGameScreen(
                        lessonNumber: lesson.lessonNumber!, userName: userName);
                    break;
                  case 'family':
                    destination = WordFamilyGameScreen(
                        lessonNumber: lesson.lessonNumber!, userName: userName);
                    break;
                  case 'antonym':
                    destination = WordAntonymGameScreen(
                        lessonNumber: lesson.lessonNumber!, userName: userName);
                    break;
                  case 'spelling':
                    destination = WordSpellingGameScreen(
                        lessonNumber: lesson.lessonNumber!, userName: userName);
                    break;
                  case 'text_lesson':
                    destination = TextLessonGameScreen(
                        lessonNumber: lesson.lessonNumber!, userName: userName);
                    break;
                  case 'negaresh':
                    destination = NegareshGameScreen(
                        lessonNumber: lesson.lessonNumber!, userName: userName);
                    break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('این بخش هنوز آماده نشده است.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    break;
                }

                if (destination != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => destination!),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
