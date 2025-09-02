import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sheshomino/widgets/app_background.dart';
import 'package:sheshomino/widgets/glass_card.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/models/social_models.dart';
import '../../../data/repositories/user_repository.dart';

class SocialQuizScreen extends StatefulWidget {
  final int chapterNumber;
  final String screenTitle;
  final int lessonNumber;
  final String userName;
  final String jsonPath;

  const SocialQuizScreen({
    super.key,
    required this.chapterNumber,
    required this.screenTitle,
    required this.lessonNumber,
    required this.userName,
    required this.jsonPath,
  });

  @override
  State<SocialQuizScreen> createState() => _SocialQuizScreenState();
}

class _SocialQuizScreenState extends State<SocialQuizScreen> {
  List<SocialQuizQuestion> _quizQuestions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _remainingTime = 30;
  String? _selectedOption;
  bool _answered = false;
  late List<String> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final String response = await rootBundle.loadString(widget.jsonPath);
      // **اصلاح نهایی و قطعی: جیسون به عنوان یک لیست خوانده می‌شود**
      final List<dynamic> chaptersList = json.decode(response);

      final chapterData = chaptersList.firstWhere(
          (d) => d['chapter_number'] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['lesson_number'] == widget.lessonNumber,
            orElse: () => null);

        if (lessonData != null) {
          final SocialQuizLesson lesson = SocialQuizLesson.fromJson(lessonData);
          _quizQuestions = lesson.questions;
          _quizQuestions.shuffle();
        }
      }
    } catch (e) {
      print("Error loading quiz from ${widget.jsonPath}: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (_quizQuestions.isNotEmpty) {
          _setupNewQuestion();
        }
      }
    }
  }

  void _setupNewQuestion() {
    _timer?.cancel();
    setState(() {
      _selectedOption = null;
      _answered = false;
      _remainingTime = 30;
      final currentQuestion = _quizQuestions[_currentQuestionIndex];
      _shuffledOptions = List<String>.from(currentQuestion.options)..shuffle();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _nextQuestion();
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    if (_answered) return;
    _timer?.cancel();
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final correctAnswerText = currentQuestion.answer;
    final userRepo = Provider.of<UserRepository>(context, listen: false);

    setState(() {
      _answered = true;
      _selectedOption = selectedAnswer;
      if (selectedAnswer == correctAnswerText) {
        _score++;
        userRepo.addCoins(10);
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _setupNewQuestion();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('پایان آزمون!'),
          content: Text('امتیاز شما: $_score از ${_quizQuestions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('بازگشت'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getOptionColor(String option) {
    if (!_answered) {
      return Colors.white.withOpacity(0.2);
    }
    if (option == _quizQuestions[_currentQuestionIndex].answer) {
      return Colors.green.withOpacity(0.5);
    }
    if (option == _selectedOption) {
      return Colors.red.withOpacity(0.5);
    }
    return Colors.white.withOpacity(0.2);
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
            : _quizQuestions.isEmpty
                ? const Center(child: Text('آزمونی برای این درس یافت نشد.'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeader(widget.userName, userCoins),
                        const SizedBox(height: 20),
                        _buildQuestionCard(),
                        const SizedBox(height: 20),
                        Expanded(child: _buildOptions()),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: _nextQuestion,
                            child: const Text("سوال بعدی")),
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
        CircleAvatar(
          radius: 25,
          backgroundColor: _remainingTime < 10 ? Colors.red : Colors.teal,
          child: Text(
            _remainingTime.toString(),
            style: TextStyle(
                fontSize: ResponsiveSizer.sp(20),
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
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

  Widget _buildQuestionCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _quizQuestions[_currentQuestionIndex].question,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: ResponsiveSizer.sp(16),
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return ListView.builder(
      itemCount: _shuffledOptions.length,
      itemBuilder: (context, index) {
        final option = _shuffledOptions[index];
        return GlassCard(
          color: _getOptionColor(option),
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: InkWell(
            onTap: _answered ? null : () => _checkAnswer(option),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: ResponsiveSizer.sp(15), color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
