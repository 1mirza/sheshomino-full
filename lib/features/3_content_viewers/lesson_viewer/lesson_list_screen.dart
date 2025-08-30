import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/lesson_model.dart';
import 'farsi_lesson_detail_screen.dart';
import 'math_lesson_detail_screen.dart';
import 'science_lesson_detail_screen.dart'; // این خط برای شناسایی منوی علوم اضافه شده

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

  // این تابع حالا به صورت هوشمند هم از جیسون و هم از لیست ثابت (برای علوم) پشتیبانی می‌کند
  Future<void> _loadLessons() async {
    // اگر مسیر فایل شامل 'oloom' باشد، لیست ثابت را بارگذاری کن
    if (widget.jsonPath.contains('oloom')) {
      _loadStaticScienceLessons();
      return; // از ادامه تابع خارج شو
    }

    // در غیر این صورت، برای سایر کتاب‌ها از فایل جیسون بخوان
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

  // این متد لیست ثابت درس‌های علوم را بر اساس کتاب درسی ایجاد می‌کند
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    initiallyExpanded: true, // همه فصل‌ها باز باشند
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
                          if (widget.jsonPath.contains('farsi')) {
                            // ... کد فارسی
                          } else if (widget.jsonPath.contains('math')) {
                            // ... کد ریاضی
                          } else if (widget.jsonPath.contains('oloom')) {
                            // **اینجا اتصال نهایی برقرار می‌شود**
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScienceLessonDetailScreen(
                                  chapterNumber: chapter.chapterNumber!,
                                  lesson: lesson,
                                ),
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
    );
  }
}
