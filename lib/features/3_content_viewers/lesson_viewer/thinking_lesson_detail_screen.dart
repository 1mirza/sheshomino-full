import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../science_content_viewer/science_content_screen.dart'; // Reusable screen
import '../thinking_content_viewer/thinking_quiz_screen.dart';

class ThinkingLessonDetailScreen extends StatefulWidget {
  final int chapterNumber;
  final Lesson lesson;

  const ThinkingLessonDetailScreen(
      {super.key, required this.chapterNumber, required this.lesson});

  @override
  State<ThinkingLessonDetailScreen> createState() =>
      _ThinkingLessonDetailScreenState();
}

class _ThinkingLessonDetailScreenState
    extends State<ThinkingLessonDetailScreen> {
  bool _hasSlides = false;
  bool _hasActivities = false;
  bool _hasQuiz = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkContentAvailability();
  }

  Future<void> _checkContentAvailability() async {
    await Future.wait([
      _checkJsonContent('assets/json_data/json_tafakor/thinking_slides.json',
          'slides', (exists) => _hasSlides = exists),
      _checkJsonContent(
          'assets/json_data/json_tafakor/thinking_activities.json',
          'activities',
          (exists) => _hasActivities = exists),
      _checkJsonContent('assets/json_data/json_tafakor/thinking_quiz.json',
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
            (l) => l['title'] == widget.lesson.title,
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
        'title': 'فعالیت‌های درس',
        'icon': Icons.edit_note,
        'page': 'activities',
        'enabled': _hasActivities
      },
      {
        'title': 'آزمون',
        'icon': Icons.quiz_outlined,
        'page': 'quiz',
        'enabled': _hasQuiz
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
      ),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                bool isEnabled = option['enabled'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 8.0),
                  child: ListTile(
                    leading: Icon(option['icon'],
                        color: isEnabled
                            ? Theme.of(context).primaryColor
                            : Colors.grey),
                    title: Text(
                      option['title'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? Colors.black : Colors.grey),
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
                        destination = ScienceContentScreen(
                          screenTitle: "جزوه: ${widget.lesson.title}",
                          chapterNumber: widget.chapterNumber,
                          lessonNumber: widget.lesson.lessonNumber ??
                              0, // Tafakor may not have lesson number
                          jsonPath:
                              'assets/json_data/json_tafakor/thinking_slides.json',
                          contentKey: 'slides',
                          numberKey: 'slide_number',
                          userName: userName,
                        );
                      } else if (option['page'] == 'activities') {
                        destination = ScienceContentScreen(
                          screenTitle: "فعالیت: ${widget.lesson.title}",
                          chapterNumber: widget.chapterNumber,
                          lessonNumber: widget.lesson.lessonNumber ?? 0,
                          jsonPath:
                              'assets/json_data/json_tafakor/thinking_activities.json',
                          contentKey: 'activities',
                          numberKey: 'activity_number',
                          userName: userName,
                        );
                      } else if (option['page'] == 'quiz') {
                        destination = ThinkingQuizScreen(
                          chapterNumber: widget.chapterNumber,
                          lessonTitle: widget.lesson.title,
                          userName: userName,
                        );
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
