import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sheshomino/widgets/app_background.dart';
import 'package:sheshomino/widgets/glass_card.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../math_content_viewer/math_slides_screen.dart';
import '../math_content_viewer/math_problems_screen.dart';
import '../math_content_viewer/math_quiz_screen.dart';

class MathLessonDetailScreen extends StatefulWidget {
  final int chapterNumber;
  final Lesson lesson;

  const MathLessonDetailScreen({
    super.key,
    required this.chapterNumber,
    required this.lesson,
  });

  @override
  State<MathLessonDetailScreen> createState() => _MathLessonDetailScreenState();
}

class _MathLessonDetailScreenState extends State<MathLessonDetailScreen> {
  bool _hasSlides = false;
  bool _hasProblems = false;
  bool _hasQuiz = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkContentAvailability();
  }

  Future<void> _checkContentAvailability() async {
    await Future.wait([
      _checkJsonContent('assets/json_data/json_riazi/mathslide.json', 'slides',
          (exists) => _hasSlides = exists),
      _checkJsonContent('assets/json_data/json_riazi/eshkalriazi.json',
          'slides', (exists) => _hasProblems = exists),
      _checkJsonContent('assets/json_data/json_riazi/math_quiz.json',
          'questions', (exists) => _hasQuiz = exists),
    ]);
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _checkJsonContent(
      String path, String key, Function(bool) updater) async {
    try {
      final String response = await rootBundle.loadString(path);
      final List<dynamic> data = json.decode(response);
      final chapterData = data.firstWhere(
          (d) => d['chapter_number'] == widget.chapterNumber,
          orElse: () => null);
      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['lesson_number'] == widget.lesson.lessonNumber,
            orElse: () => null);
        if (lessonData != null &&
            lessonData[key] != null &&
            (lessonData[key] as List).isNotEmpty) {
          updater(true);
        } else {
          updater(false);
        }
      } else {
        updater(false);
      }
    } catch (_) {
      updater(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepo = Provider.of<UserRepository>(context, listen: false);
    final userName = userRepo.userProfile?.name ?? "دانش‌آموز";

    final List<Map<String, dynamic>> options = [
      {
        'title': 'جزوه آموزشی',
        'icon': Icons.book_outlined,
        'page': 'slides',
        'enabled': _hasSlides
      },
      {
        'title': 'اشکالات رایج دانش‌آموزان',
        'icon': Icons.report_problem_outlined,
        'page': 'problems',
        'enabled': _hasProblems
      },
      {
        'title': 'آزمون',
        'icon': Icons.quiz_outlined,
        'page': 'quiz',
        'enabled': _hasQuiz
      },
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isChecking
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  bool isEnabled = option['enabled'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GlassCard(
                      child: ListTile(
                        leading: Icon(option['icon'],
                            color: isEnabled
                                ? Theme.of(context).primaryColor
                                : Colors.grey),
                        title: Text(
                          option['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isEnabled ? Colors.black87 : Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        enabled: isEnabled,
                        onTap: () {
                          if (!isEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'محتوایی برای بخش "${option['title']}" یافت نشد.'),
                                  backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          Widget? destination;
                          if (option['page'] == 'slides') {
                            destination = MathSlidesScreen(
                              chapterNumber: widget.chapterNumber,
                              lessonNumber: widget.lesson.lessonNumber!,
                              lessonTitle: widget.lesson.title,
                              userName: userName,
                            );
                          } else if (option['page'] == 'problems') {
                            destination = MathProblemsScreen(
                              chapterNumber: widget.chapterNumber,
                              lessonNumber: widget.lesson.lessonNumber!,
                              lessonTitle: widget.lesson.title,
                              userName: userName,
                            );
                          } else if (option['page'] == 'quiz') {
                            destination = MathQuizScreen(
                              chapterNumber: widget.chapterNumber,
                              lessonNumber: widget.lesson.lessonNumber!,
                              lessonTitle: widget.lesson.title,
                              userName: userName,
                            );
                          }

                          if (destination != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => destination!),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
