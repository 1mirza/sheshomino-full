import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/models/math_lesson_model.dart';
import '../../../data/repositories/user_repository.dart';

// این صفحه برای نمایش اسلایدهای اشکالات رایج است
class MathProblemsScreen extends StatefulWidget {
  final int chapterNumber;
  final int lessonNumber;
  final String lessonTitle;
  final String userName;

  const MathProblemsScreen({
    super.key,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.lessonTitle,
    required this.userName,
  });

  @override
  State<MathProblemsScreen> createState() => _MathProblemsScreenState();
}

class _MathProblemsScreenState extends State<MathProblemsScreen> {
  List<MathSlide> _slides = [];
  bool _isLoading = true;
  int _currentSlideIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    try {
      final String response = await rootBundle
          .loadString('assets/json_data/json_riazi/eshkalriazi.json');
      final List<dynamic> chaptersList = json.decode(response);

      final chapterData = chaptersList.firstWhere(
          (chapter) => chapter['chapter_number'] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final List<dynamic> lessonsList = chapterData['lessons'];
        final lessonData = lessonsList.firstWhere(
            (lesson) => lesson['lesson_number'] == widget.lessonNumber,
            orElse: () => null);

        if (lessonData != null) {
          // از همان مدل MathLesson استفاده می‌کنیم چون ساختار جیسون مشابه است
          final MathLesson lesson = MathLesson.fromJson(lessonData);
          _slides = lesson.slides;
        }
      }
    } catch (e) {
      print("!!! CRITICAL ERROR loading problems slides: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToNextSlide() {
    if (_currentSlideIndex < _slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
    } else {
      Navigator.of(context).pop(); // بازگشت به منوی درس
    }
  }

  void _goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSizer.init(context);
    final userRepo = Provider.of<UserRepository>(context);
    final userCoins = userRepo.userProfile?.coins ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("اشکالات رایج: ${widget.lessonTitle}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _slides.isEmpty
              ? const Center(child: Text('محتوایی برای این بخش یافت نشد.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeader(widget.userName, userCoins),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Card(
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _slides[_currentSlideIndex].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: ResponsiveSizer.sp(18),
                                      fontWeight: FontWeight.bold),
                                ),
                                const Divider(height: 30),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _slides[_currentSlideIndex].content,
                                      style: TextStyle(
                                          fontSize: ResponsiveSizer.sp(15),
                                          height: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildNavigationControls(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(String name, int coins) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(),
            const SizedBox(width: 8),
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveSizer.sp(14))),
          ],
        ),
        Text(
          'اسلاید ${_currentSlideIndex + 1} از ${_slides.length}',
          style: TextStyle(
              fontSize: ResponsiveSizer.sp(15), fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text('$coins',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveSizer.sp(16))),
            const SizedBox(width: 4),
            const Icon(Icons.monetization_on, color: Colors.amber),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: _currentSlideIndex > 0 ? _goToPreviousSlide : null,
          icon: const Icon(Icons.arrow_back_ios),
          label: const Text('قبلی'),
        ),
        ElevatedButton.icon(
          onPressed: _goToNextSlide,
          icon: const Icon(Icons.arrow_forward_ios),
          label: Text(
            _currentSlideIndex == _slides.length - 1 ? 'بازگشت' : 'بعدی',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
        ),
      ],
    );
  }
}
