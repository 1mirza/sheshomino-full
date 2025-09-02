import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sheshomino/widgets/app_background.dart';
import 'package:sheshomino/widgets/glass_card.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/repositories/user_repository.dart';

// Models specific to this screen for clarity
class ContentSlide {
  final int number;
  final String title;
  final String content;

  ContentSlide(
      {required this.number, required this.title, required this.content});

  factory ContentSlide.fromJson(Map<String, dynamic> json, String numberKey) {
    return ContentSlide(
      number: json[numberKey],
      title: json['title'],
      content: json['content'],
    );
  }
}

class ContentLesson {
  final int lessonNumber;
  final String title;
  final List<ContentSlide> slides;

  ContentLesson(
      {required this.lessonNumber, required this.title, required this.slides});

  factory ContentLesson.fromJson(
      Map<String, dynamic> json, String contentKey, String numberKey) {
    var contentList = json[contentKey] as List? ?? [];
    List<ContentSlide> parsedSlides =
        contentList.map((s) => ContentSlide.fromJson(s, numberKey)).toList();
    return ContentLesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      slides: parsedSlides,
    );
  }
}

class SocialContentScreen extends StatefulWidget {
  final String screenTitle;
  final int chapterNumber;
  final int lessonNumber;
  final String jsonPath;
  final String contentKey; // 'slides'
  final String numberKey; // 'slide_number'
  final String userName;

  const SocialContentScreen({
    super.key,
    required this.screenTitle,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.jsonPath,
    required this.contentKey,
    required this.numberKey,
    required this.userName,
  });

  @override
  State<SocialContentScreen> createState() => _SocialContentScreenState();
}

class _SocialContentScreenState extends State<SocialContentScreen> {
  List<ContentSlide> _slides = [];
  bool _isLoading = true;
  int _currentSlideIndex = 0;
  final Set<int> _viewedSlides = {};

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final String response = await rootBundle.loadString(widget.jsonPath);
      final List<dynamic> data = json.decode(response);
      final chapterData = data.firstWhere(
          (d) => d['chapter_number'] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['lesson_number'] == widget.lessonNumber,
            orElse: () => null);

        if (lessonData != null) {
          final ContentLesson lesson = ContentLesson.fromJson(
              lessonData, widget.contentKey, widget.numberKey);
          _slides = lesson.slides;
        }
      }
    } catch (e) {
      print("Error loading content from ${widget.jsonPath}: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _awardInitialCoin();
      }
    }
  }

  void _awardInitialCoin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_slides.isNotEmpty && mounted) {
        final userRepo = Provider.of<UserRepository>(context, listen: false);
        userRepo.addCoins(5);
        _viewedSlides.add(0);
      }
    });
  }

  void _goToNextSlide() {
    if (_currentSlideIndex < _slides.length - 1) {
      setState(() => _currentSlideIndex++);
      _awardCoinForNewSlide();
    } else {
      _showCompletionDialog();
    }
  }

  void _goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() => _currentSlideIndex--);
    }
  }

  void _awardCoinForNewSlide() {
    if (!_viewedSlides.contains(_currentSlideIndex)) {
      final userRepo = Provider.of<UserRepository>(context, listen: false);
      userRepo.addCoins(5);
      _viewedSlides.add(_currentSlideIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ۵ سکه جایزه گرفتی!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تبریک!'),
          content: const Text('شما تمام بخش‌های این قسمت را مشاهده کردید.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('بازگشت به منوی درس'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSizer.init(context);
    final userRepo = Provider.of<UserRepository>(context);
    final userCoins = userRepo.userProfile?.coins ?? 0;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.screenTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                          child: GlassCard(
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
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                  const Divider(height: 30),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _slides[_currentSlideIndex].content,
                                        style: TextStyle(
                                            fontSize: ResponsiveSizer.sp(15),
                                            height: 1.5,
                                            color:
                                                Colors.black.withOpacity(0.7)),
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
                    fontSize: ResponsiveSizer.sp(14),
                    color: Colors.white)),
          ],
        ),
        Text(
          'صفحه ${_currentSlideIndex + 1} از ${_slides.length}',
          style: TextStyle(
              fontSize: ResponsiveSizer.sp(15),
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        Row(
          children: [
            Text('$coins',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveSizer.sp(16),
                    color: Colors.white)),
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
            _currentSlideIndex == _slides.length - 1 ? 'پایان' : 'بعدی',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }
}
