import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/models/science_models.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ScienceContentScreen extends StatefulWidget {
  final String screenTitle;
  final int chapterNumber;
  final int lessonNumber;
  final String jsonPath;
  final String contentKey;
  final String numberKey;
  final String userName;
  final String
      chapterIdentifierKey; // New optional parameter for keys like 'poodeman_number'

  const ScienceContentScreen({
    super.key,
    required this.screenTitle,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.jsonPath,
    required this.contentKey,
    required this.numberKey,
    required this.userName,
    this.chapterIdentifierKey = 'chapter_number', // Default value
  });

  @override
  State<ScienceContentScreen> createState() => _ScienceContentScreenState();
}

class _ScienceContentScreenState extends State<ScienceContentScreen> {
  List<dynamic> _contentSlides = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadContent();
    Provider.of<ActivityRepository>(context, listen: false)
        .startTracking(widget.screenTitle);
  }

  @override
  void dispose() {
    _pageController.dispose();
    Provider.of<ActivityRepository>(context, listen: false).stopTracking();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final String response = await rootBundle.loadString(widget.jsonPath);
      final List<dynamic> data = json.decode(response);

      // Use the dynamic identifier key to find the chapter/poodeman
      final chapterData = data.firstWhere(
          (d) => d[widget.chapterIdentifierKey] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['lesson_number'] == widget.lessonNumber,
            orElse: () => null);

        if (lessonData != null && lessonData[widget.contentKey] != null) {
          _contentSlides = lessonData[widget.contentKey];
        }
      }
    } catch (e) {
      print("Error loading content from ${widget.jsonPath}: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showCompletionDialog() {
    final userRepo = Provider.of<UserRepository>(context, listen: false);
    userRepo.addCoins(20);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آفرین!'),
        content: const Text(
            'شما این بخش را با موفقیت به پایان رساندید و ۲۰ سکه جایزه گرفتید!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSizer.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.screenTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contentSlides.isEmpty
              ? const Center(child: Text('محتوایی برای نمایش یافت نشد.'))
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _contentSlides.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final slide = _contentSlides[index];
                          return Card(
                            margin: const EdgeInsets.all(16.0),
                            elevation: 4,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    slide['title'] ?? slide['question'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ResponsiveSizer.sp(18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    slide['content'] ?? slide['answer'] ?? '',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontSize: ResponsiveSizer.sp(16),
                                        height: 1.8),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildNavigationControls(),
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('اسلاید ${_currentIndex + 1} از ${_contentSlides.length}'),
          Row(
            children: [
              Text(widget.userName),
              const SizedBox(width: 8),
              const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _currentIndex > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                : null,
            child: const Text('قبلی'),
          ),
          ElevatedButton(
            onPressed: _currentIndex < _contentSlides.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                : _showCompletionDialog,
            child: Text(
                _currentIndex < _contentSlides.length - 1 ? 'بعدی' : 'پایان'),
          ),
        ],
      ),
    );
  }
}
