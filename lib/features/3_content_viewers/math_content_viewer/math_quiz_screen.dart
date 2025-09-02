import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sheshomino/data/models/quiz_result_model.dart';
import 'package:sheshomino/features/2_quiz/screens/quiz_result_screen.dart';
import 'package:sheshomino/widgets/app_background.dart';
import 'package:sheshomino/widgets/glass_card.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/models/math_quiz_model.dart';
import '../../../data/repositories/user_repository.dart';

class MathQuizScreen extends StatefulWidget {
  final int chapterNumber;
  final int lessonNumber;
  final String lessonTitle;
  final String userName;

  const MathQuizScreen({
    super.key,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.lessonTitle,
    required this.userName,
  });

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  List<MathQuizQuestion> _allQuestions = [];
  List<MathQuizQuestion> _quizQuestions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  Timer? _questionTimer;
  Timer? _feedbackTimer;
  int _remainingTime = 30;
  String? _selectedOption;
  bool _answered = false;
  List<String> _shuffledOptions = [];

  final List<QuestionResult> _results = [];

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final String response = await rootBundle
          .loadString('assets/json_data/json_riazi/math_quiz.json');
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
          final MathQuizLesson lesson = MathQuizLesson.fromJson(lessonData);
          _allQuestions = lesson.questions;
          _allQuestions.shuffle();
          _quizQuestions = _allQuestions.take(10).toList();
        }
      }
    } catch (e) {
      print("!!! CRITICAL ERROR loading quiz: $e");
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

  void _startTimer() {
    _questionTimer?.cancel();
    setState(() {
      _remainingTime = 30;
    });
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _handleTimeout();
      }
    });
  }

  void _setupNewQuestion() {
    setState(() {
      _selectedOption = null;
      _answered = false;
      final question = _quizQuestions[_currentQuestionIndex];
      _shuffledOptions = List.from(question.options)..shuffle();
    });
    _startTimer();
  }

  void _checkAnswer(String option) {
    if (_answered) return;

    _questionTimer?.cancel();
    final question = _quizQuestions[_currentQuestionIndex];
    final isCorrect = option == question.correctAnswer;

    _results.add(QuestionResult(
      question: question.questionText,
      selectedAnswer: option,
      correctAnswer: question.correctAnswer,
      isCorrect: isCorrect,
    ));

    setState(() {
      _answered = true;
      _selectedOption = option;
    });

    if (isCorrect) {
      final userRepo = Provider.of<UserRepository>(context, listen: false);
      userRepo.addCoins(10);
    }

    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _advanceToNextStep();
      }
    });
  }

  void _handleTimeout() {
    if (!mounted || _answered) return;
    _questionTimer?.cancel();
    final question = _quizQuestions[_currentQuestionIndex];

    _results.add(QuestionResult(
      question: question.questionText,
      selectedAnswer: "پاسخی داده نشد",
      correctAnswer: question.correctAnswer,
      isCorrect: false,
    ));

    setState(() {
      _answered = true;
      _selectedOption = null;
    });

    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _advanceToNextStep();
      }
    });
  }

  void _advanceToNextStep() {
    if (!mounted) return;
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _setupNewQuestion();
    } else {
      _showResultScreen();
    }
  }

  void _showResultScreen() {
    if (!mounted) return;
    _questionTimer?.cancel();
    _feedbackTimer?.cancel();

    final userRepo = Provider.of<UserRepository>(context, listen: false);
    final quizResult = QuizResult(
      bookTitle: "ریاضی",
      lessonTitle: widget.lessonTitle,
      score: _results.where((r) => r.isCorrect).length,
      totalQuestions: _quizQuestions.length,
      date: DateTime.now(),
      results: _results,
    );
    userRepo.addQuizResult(quizResult);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(result: quizResult),
      ),
    );
  }

  Color _getOptionColor(String option) {
    if (!_answered) {
      return Colors.white.withOpacity(0.7);
    }
    final question = _quizQuestions[_currentQuestionIndex];
    if (option == question.correctAnswer) {
      return Colors.green.shade200;
    }
    if (option == _selectedOption) {
      return Colors.red.shade200;
    }
    return Colors.white.withOpacity(0.7);
  }

  Future<bool> _onBackPressed() async {
    _questionTimer?.cancel();
    _feedbackTimer?.cancel();
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('خروج از آزمون'),
          content: const Text(
              'آیا می‌خواهید از آزمون خارج شوید؟ پیشرفت شما ذخیره نخواهد شد.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('نه، ادامه میدم'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('بله، خارج شو'),
            ),
          ],
        ),
      ),
    );
    if (shouldPop ?? false) {
      return true;
    } else {
      _startTimer();
      return false;
    }
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
          title: Text("آزمون: ${widget.lessonTitle}"),
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: _answered
                                ? null
                                : () {
                                    _handleTimeout();
                                  },
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
          backgroundColor: _remainingTime < 10
              ? Colors.red.withOpacity(0.7)
              : Colors.teal.withOpacity(0.7),
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
          _quizQuestions[_currentQuestionIndex].questionText,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: ResponsiveSizer.sp(16),
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return ListView.builder(
      itemCount: _shuffledOptions.length,
      itemBuilder: (context, index) {
        final option = _shuffledOptions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: InkWell(
            onTap: _answered ? null : () => _checkAnswer(option),
            child: GlassCard(
              child: Container(
                color: _getOptionColor(option),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    option,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: ResponsiveSizer.sp(15),
                        color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
