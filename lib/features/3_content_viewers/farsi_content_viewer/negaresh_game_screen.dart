import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/responsive_sizer.dart';
import '../../../../data/models/farsi_content_model.dart';
import '../../../../data/models/quiz_result_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../2_quiz/screens/quiz_result_screen.dart';

class NegareshGameScreen extends StatefulWidget {
  final int lessonNumber;
  final String userName;

  const NegareshGameScreen({
    super.key,
    required this.lessonNumber,
    required this.userName,
  });

  @override
  State<NegareshGameScreen> createState() => _NegareshGameScreenState();
}

class _NegareshGameScreenState extends State<NegareshGameScreen> {
  Timer? _timer;
  int _remainingTime = 30;
  List<NegareshQuestion> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  String? _selectedOption;
  bool _answered = false;
  List<String> _currentOptions = [];

  // متغیر جدید برای ذخیره عنوان درس
  String _lessonTitleForQuiz = '';

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
          .loadString('assets/json_data/farsi_json/negaresh.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> chapters = data['chapters'];

      NegareshLesson? lesson;
      for (var chapter in chapters) {
        final List<dynamic> lessons = chapter['lessons'];
        final lessonData = lessons.firstWhere(
            (l) => l['lesson_number'] == widget.lessonNumber,
            orElse: () => null);
        if (lessonData != null) {
          lesson = NegareshLesson.fromJson(lessonData);
          break;
        }
      }

      if (lesson != null) {
        _quizQuestions = lesson.questions;
        _lessonTitleForQuiz = lesson.lessonTitle; // ذخیره عنوان درس
        _quizQuestions.shuffle();

        if (_quizQuestions.isNotEmpty) {
          _setupNewQuestion();
        }
      }
    } catch (e) {
      print("Error loading negaresh game: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
      _currentOptions =
          List<String>.from(_quizQuestions[_currentQuestionIndex].options)
            ..shuffle();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _checkAnswer(String selectedOption) {
    if (_answered) return;
    _timer?.cancel();
    _answered = true;
    _selectedOption = selectedOption;

    final userRepo = Provider.of<UserRepository>(context, listen: false);
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final bool isCorrect = selectedOption == currentQuestion.correctAnswer;

    if (isCorrect) {
      userRepo.addCoins(10);
    }

    _quizResults.add(QuestionResult(
      question: currentQuestion.questionText,
      selectedAnswer: selectedOption,
      correctAnswer: currentQuestion.correctAnswer,
      isCorrect: isCorrect,
    ));

    setState(() {});

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _goToNextQuestion();
    });
  }

  void _handleTimeout() {
    if (_answered) return;
    _timer?.cancel();
    _answered = true;

    final currentQuestion = _quizQuestions[_currentQuestionIndex];

    _quizResults.add(QuestionResult(
      question: currentQuestion.questionText,
      selectedAnswer: "پاسخ داده نشد",
      correctAnswer: currentQuestion.correctAnswer,
      isCorrect: false,
    ));

    setState(() {});

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _goToNextQuestion();
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
      bookTitle: 'نگارش فارسی',
      lessonTitle: _lessonTitleForQuiz,
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
      appBar: AppBar(title: Text('آزمون نگارش: $_lessonTitleForQuiz')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizQuestions.isEmpty
              ? const Center(child: Text('سؤالی برای این درس یافت نشد.'))
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
        padding: const EdgeInsets.all(20.0),
        child: Text(
          _quizQuestions[_currentQuestionIndex].questionText,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: ResponsiveSizer.sp(16), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    final question = _quizQuestions[_currentQuestionIndex];
    final options = _currentOptions;

    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        Color? tileColor;
        Icon? trailingIcon;

        if (_answered) {
          if (option == question.correctAnswer) {
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
