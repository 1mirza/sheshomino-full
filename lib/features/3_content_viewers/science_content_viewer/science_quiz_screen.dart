import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/responsive_sizer.dart';
import '../../../../data/models/quiz_result_model.dart';
import '../../../../data/models/science_models.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../2_quiz/screens/quiz_result_screen.dart';

class ScienceQuizScreen extends StatefulWidget {
  final int chapterNumber;
  final int lessonNumber;
  final String lessonTitle;
  final String userName;

  const ScienceQuizScreen({
    super.key,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.lessonTitle,
    required this.userName,
  });

  @override
  State<ScienceQuizScreen> createState() => _ScienceQuizScreenState();
}

class _ScienceQuizScreenState extends State<ScienceQuizScreen> {
  Timer? _timer;
  int _remainingTime = 30;
  List<ScienceQuizQuestion> _allQuestions = [];
  List<ScienceQuizQuestion> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  String? _selectedOption;
  bool _answered = false;
  List<String> _currentOptions = [];

  // لیست برای ذخیره نتایج سوالات
  final List<QuestionResult> _quizResults = [];

  @override
  void initState() {
    super.initState();
    _loadAndSetupGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAndSetupGame() async {
    try {
      final String response = await rootBundle
          .loadString('assets/json_data/json_oloom/science_quiz.json');
      final List<dynamic> data = json.decode(response);
      final chapterData = data.firstWhere(
          (d) => d['chapter_number'] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['lesson_number'] == widget.lessonNumber,
            orElse: () => null);

        if (lessonData != null) {
          final ScienceQuizLesson lesson =
              ScienceQuizLesson.fromJson(lessonData);
          _allQuestions = lesson.questions;
          _allQuestions.shuffle();
          // انتخاب حداکثر ۱۰ سوال برای آزمون
          _quizQuestions = _allQuestions.take(10).toList();
        }
      }
    } catch (e) {
      print("Error loading science quiz: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (_quizQuestions.isNotEmpty) {
          _setupNewQuestion();
        }
      }
    }
  }

  void _setupNewQuestion() {
    if (_currentQuestionIndex >= _quizQuestions.length) {
      _showResultScreen();
      return;
    }
    setState(() {
      _remainingTime = 30;
      _answered = false;
      _selectedOption = null;
      _currentOptions = _quizQuestions[_currentQuestionIndex]
          .options
          .values
          .toList()
        ..shuffle();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    if (_answered) return;
    _timer?.cancel();
    _answered = true;
    _selectedOption = selectedAnswer;

    final userRepo = Provider.of<UserRepository>(context, listen: false);
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final correctKey = currentQuestion.answer;
    final correctAnswerText = currentQuestion.options[correctKey]!;

    final bool isCorrect = selectedAnswer == correctAnswerText;

    if (isCorrect) {
      userRepo.addCoins(10);
    }

    // ذخیره نتیجه سوال
    _quizResults.add(QuestionResult(
      question: currentQuestion.question,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswerText,
      isCorrect: isCorrect,
    ));

    setState(() {}); // برای نمایش فوری رنگ‌ها

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _goToNextQuestion();
      }
    });
  }

  void _handleTimeout() {
    if (_answered) return;
    _timer?.cancel();
    _answered = true;

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final correctKey = currentQuestion.answer;
    final correctAnswerText = currentQuestion.options[correctKey]!;

    _quizResults.add(QuestionResult(
      question: currentQuestion.question,
      selectedAnswer: "پاسخ داده نشد",
      correctAnswer: correctAnswerText,
      isCorrect: false,
    ));

    setState(() {});

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() => _currentQuestionIndex++);
      _setupNewQuestion();
    } else {
      _showResultScreen();
    }
  }

  void _showResultScreen() {
    final userRepo = Provider.of<UserRepository>(context, listen: false);

    final quizResult = QuizResult(
      bookTitle: 'علوم',
      lessonTitle: widget.lessonTitle,
      score: _quizResults.where((r) => r.isCorrect).length,
      totalQuestions: _quizQuestions.length,
      date: DateTime.now(),
      results: _quizResults,
    );

    userRepo.addQuizResult(quizResult);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(result: quizResult),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSizer.init(context);
    final userRepo = Provider.of<UserRepository>(context);
    final userCoins = userRepo.userProfile?.coins ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('آزمون: ${widget.lessonTitle}')),
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
                      Expanded(child: _buildOptionsList()),
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
                    fontSize: ResponsiveSizer.sp(16))),
            const SizedBox(width: 4),
            const Icon(Icons.monetization_on, color: Colors.amber),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _quizQuestions[_currentQuestionIndex].question,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: ResponsiveSizer.sp(16), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    final question = _quizQuestions[_currentQuestionIndex];
    final correctKey = question.answer;
    final correctAnswerText = question.options[correctKey]!;

    return ListView.builder(
      itemCount: _currentOptions.length,
      itemBuilder: (context, index) {
        final option = _currentOptions[index];
        Color? tileColor;
        Icon? trailingIcon;

        if (_answered) {
          if (option == correctAnswerText) {
            tileColor = Colors.green.shade100;
            trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
          } else if (option == _selectedOption) {
            tileColor = Colors.red.shade100;
            trailingIcon = const Icon(Icons.cancel, color: Colors.red);
          }
        }

        return Card(
          color: tileColor,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            title: Text(
              option,
              style: TextStyle(fontSize: ResponsiveSizer.sp(15)),
            ),
            onTap: _answered ? null : () => _checkAnswer(option),
            trailing: trailingIcon,
          ),
        );
      },
    );
  }
}
