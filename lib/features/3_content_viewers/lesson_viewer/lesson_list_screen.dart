import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/lesson_model.dart';
import 'farsi_lesson_detail_screen.dart';

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
    try {
      final String response = await rootBundle.loadString(widget.jsonPath);
      final List<dynamic> data = json.decode(response);

      if (data.isNotEmpty && (data.first.containsKey('lessons'))) {
        _chapters = data.map((json) => Chapter.fromJson(json)).toList();
      } else {
        List<Lesson> lessons =
            data.map((json) => Lesson.fromJson(json)).toList();
        _chapters = [
          Chapter(chapterTitle: 'فهرست دروس', lessons: lessons),
        ];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading lessons from ${widget.jsonPath}: $e");
    }
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
                    initiallyExpanded: _chapters.length == 1,
                    leading: chapter.chapterNumber != null
                        ? CircleAvatar(
                            child: Text(chapter.chapterNumber.toString()))
                        : const Icon(Icons.list_alt),
                    title: Text(
                      chapter.chapterTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: chapter.lessons.map((lesson) {
                      final bool isAzadLesson =
                          lesson.title.contains('درس آزاد');
                      final bool isClickableFarsiLesson =
                          widget.jsonPath.contains('farsi') &&
                              lesson.type == 'درس' &&
                              !isAzadLesson;

                      return ListTile(
                        title: Text(lesson.title),
                        trailing: lesson.type != null
                            ? Chip(
                                label: Text(lesson.type!),
                                backgroundColor:
                                    (isClickableFarsiLesson || isAzadLesson)
                                        ? null
                                        : Colors.grey.shade300,
                              )
                            : null,
                        leading: lesson.isElective
                            ? const Icon(Icons.star_border, color: Colors.amber)
                            : const Icon(Icons.class_outlined),
                        enabled: (isClickableFarsiLesson || isAzadLesson),
                        onTap: () {
                          if (isClickableFarsiLesson) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FarsiLessonDetailScreen(lesson: lesson),
                              ),
                            );
                          } else if (isAzadLesson) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'این درس آزاد است و محتوای پرسشی ندارد.'),
                                duration: Duration(seconds: 2),
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
