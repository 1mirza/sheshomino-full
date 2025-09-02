import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/technology_models.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/repositories/user_repository.dart';

class TechnologyQuizScreen extends StatefulWidget {
  final int chapterNumber; // This will hold the 'poodeman_number'
  final int lessonNumber;
  final String lessonTitle;
  final String userName;

  const TechnologyQuizScreen({
    super.key,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.lessonTitle,
    required this.userName,
  });

  @override
  State<TechnologyQuizScreen> createState() => _TechnologyQuizScreenState();
}

class _TechnologyQuizScreenState extends State<TechnologyQuizScreen> {
  List<TechnologyQuizQuestion> _quizQuestions = [];
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
    Provider.of<ActivityRepository>(context, listen: false)
        .startTracking('فناوری');
  }

  @override
  void dispose() {
    _timer?.cancel();
    Provider.of<ActivityRepository>(context, listen: false).stopTracking();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final String response = await rootBundle
          .loadString('assets/json_data/json_fanavari/technology_quiz.json');
      final List<dynamic> data = json.decode(response);

      final chapterData = data.firstWhere(
          (d) => d['poodeman_number'] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['lesson_number'] == widget.lessonNumber,
            orElse: () => null);

        if (lessonData != null) {
          final lesson = TechnologyQuizLesson.fromJson(lessonData);
          _quizQuestions = lesson.questions;
          _quizQuestions.shuffle();
        }
      }
    } catch (e) {
      print("Error loading technology quiz: $e");
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
    if (!mounted) return;
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
      if (!mounted) return;
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        _goToNextQuestion();
      }
    });
  }

  void _checkAnswer(String option) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = option;
      if (option == _quizQuestions[_currentQuestionIndex].answer) {
        _score++;
        Provider.of<UserRepository>(context, listen: false).addCoins(10);
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _goToNextQuestion();
    });
  }

  void _goToNextQuestion() {
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
    _timer?.cancel();
    final activityRepo =
        Provider.of<ActivityRepository>(context, listen: false);
    activityRepo.addQuizResult(QuizResult(
      subject: 'فناوری',
      lessonTitle: widget.lessonTitle,
      score: _score,
      totalQuestions: _quizQuestions.length,
      date: DateTime.now(),
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
    );
  }

  Color _getOptionColor(String option) {
    if (!_answered) return Colors.grey.shade200;
    if (option == _quizQuestions[_currentQuestionIndex].answer)
      return Colors.green.shade200;
    if (option == _selectedOption) return Colors.red.shade200;
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSizer.init(context);
    final userCoins =
        Provider.of<UserRepository>(context).userProfile?.coins ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text("آزمون: ${widget.lessonTitle}")),
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
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: _goToNextQuestion,
                          child: const Text("سوال بعدی"))
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(String name, int coins) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          const CircleAvatar(),
          const SizedBox(width: 8),
          Text(name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveSizer.sp(14)))
        ]),
        CircleAvatar(
            radius: 25,
            backgroundColor: _remainingTime < 10 ? Colors.red : Colors.teal,
            child: Text(_remainingTime.toString(),
                style: TextStyle(
                    fontSize: ResponsiveSizer.sp(20),
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
        Row(children: [
          Text('$coins',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveSizer.sp(16))),
          const SizedBox(width: 4),
          const Icon(Icons.monetization_on, color: Colors.amber)
        ]),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _quizQuestions[_currentQuestionIndex]
              .question, // Corrected from questionText
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: ResponsiveSizer.sp(16), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    return ListView.builder(
      itemCount: _shuffledOptions.length,
      itemBuilder: (context, index) {
        final option = _shuffledOptions[index];
        return Card(
          color: _getOptionColor(option),
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: InkWell(
            onTap: _answered ? null : () => _checkAnswer(option),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(option,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ResponsiveSizer.sp(15))),
            ),
          ),
        );
      },
    );
  }
}
