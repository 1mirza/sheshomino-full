import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheshomino/widgets/app_background.dart';
import 'package:sheshomino/widgets/glass_card.dart';
import '../../../data/models/lesson_model.dart';
import 'farsi_lesson_detail_screen.dart';
import 'math_lesson_detail_screen.dart';
import 'science_lesson_detail_screen.dart';
import 'social_lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String bookTitle;
  final String jsonPath;

  const LessonListScreen({
    super.key,
    required this.bookTitle,
    required this.jsonPath,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  List<Chapter> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    // **اصلاح اساسی:** برای تشخیص کتاب علوم، از عنوان کتاب استفاده می‌کنیم که روش مطمئن‌تری است
    if (widget.bookTitle.contains('علوم')) {
      _loadStaticScienceLessons();
      return;
    }

    try {
      final String response = await rootBundle.loadString(widget.jsonPath);
      final List<dynamic> data = json.decode(response);
      _chapters = data.map((json) => Chapter.fromJson(json)).toList();
    } catch (e) {
      print("Error loading lessons from ${widget.jsonPath}: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadStaticScienceLessons() {
    _chapters = [
      Chapter(chapterNumber: 1, chapterTitle: "زنگ علوم", lessons: [
        Lesson(lessonNumber: 1, title: "زنگ علوم"),
      ]),
      Chapter(chapterNumber: 2, chapterTitle: "مواد در زندگی", lessons: [
        Lesson(lessonNumber: 2, title: "سرگذشت دفتر من"),
        Lesson(lessonNumber: 3, title: "کارخانه ی کاغذسازی"),
      ]),
      Chapter(chapterNumber: 3, chapterTitle: "زمین پویا", lessons: [
        Lesson(lessonNumber: 4, title: "سفر به اعماق زمین"),
        Lesson(lessonNumber: 5, title: "زمین پویا"),
      ]),
      Chapter(chapterNumber: 4, chapterTitle: "ورزش و نیرو", lessons: [
        Lesson(lessonNumber: 6, title: "ورزش و نیرو (۱)"),
        Lesson(lessonNumber: 7, title: "ورزش و نیرو (۲)"),
      ]),
      Chapter(chapterNumber: 5, chapterTitle: "طراحی و ساخت", lessons: [
        Lesson(lessonNumber: 8, title: "طراحی کنیم و بسازیم"),
      ]),
      Chapter(chapterNumber: 6, chapterTitle: "انرژی", lessons: [
        Lesson(lessonNumber: 9, title: "سفر انرژی"),
      ]),
      Chapter(chapterNumber: 7, chapterTitle: "دنیای زنده", lessons: [
        Lesson(lessonNumber: 10, title: "خیلی کوچک خیلی بزرگ"),
        Lesson(lessonNumber: 11, title: "شگفتی های برگ"),
        Lesson(lessonNumber: 12, title: "جنگل برای کیست؟"),
      ]),
      Chapter(chapterNumber: 8, chapterTitle: "سلامتی و فناوری", lessons: [
        Lesson(lessonNumber: 13, title: "سالم بمانیم"),
        Lesson(lessonNumber: 14, title: "از گذشته تا آینده"),
      ]),
    ];
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.bookTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _chapters[index];
                  return GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      leading: CircleAvatar(
                        child: Text(chapter.chapterNumber.toString()),
                      ),
                      title: Text(
                        chapter.chapterTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: chapter.lessons.map((lesson) {
                        return ListTile(
                          title: Text(lesson.title),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Widget? destination;

                            // **اصلاح اساسی:** منطق برنامه به حالت صحیح بازگردانده شد
                            if (widget.bookTitle.contains('فارسی')) {
                              destination =
                                  FarsiLessonDetailScreen(lesson: lesson);
                            } else if (widget.bookTitle.contains('ریاضی')) {
                              destination = MathLessonDetailScreen(
                                  chapterNumber: chapter.chapterNumber!,
                                  lesson: lesson);
                            } else if (widget.bookTitle.contains('علوم')) {
                              destination = ScienceLessonDetailScreen(
                                chapterNumber: chapter.chapterNumber!,
                                lesson: lesson,
                              );
                            } else if (widget.bookTitle.contains('اجتماعی')) {
                              destination = SocialLessonDetailScreen(
                                  chapterNumber: chapter.chapterNumber!,
                                  lesson: lesson);
                            }

                            if (destination != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => destination!),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'صفحه جزئیات این کتاب هنوز آماده نشده است.'),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
