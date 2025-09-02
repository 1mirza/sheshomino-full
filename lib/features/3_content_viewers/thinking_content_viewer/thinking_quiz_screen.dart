import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/thinking_models.dart';
import '../../../data/repositories/user_repository.dart';

class ThinkingQuizScreen extends StatefulWidget {
  final int chapterNumber;
  final String lessonTitle;
  final String userName;

  const ThinkingQuizScreen({
    super.key,
    required this.chapterNumber,
    required this.lessonTitle,
    required this.userName,
  });

  @override
  State<ThinkingQuizScreen> createState() => _ThinkingQuizScreenState();
}

class _ThinkingQuizScreenState extends State<ThinkingQuizScreen> {
  Timer? _timer;
  int _remainingTime = 30;
  List<ThinkingQuizQuestion> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  int? _selectedOptionIndex;
  Color? _feedbackColor;
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
      final String response = await rootBundle
          .loadString('assets/json_data/json_tafakor/thinking_quiz.json');
      final List<dynamic> data = json.decode(response);
      final chapterData = data.firstWhere(
          (d) => d['chapter_number'] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['title'] == widget.lessonTitle,
            orElse: () => null);

        if (lessonData != null) {
          final ThinkingQuizLesson lesson =
              ThinkingQuizLesson.fromJson(lessonData);
          _quizQuestions = lesson.questions;
          _quizQuestions.shuffle();
        }
      }
    } catch (e) {
      print("Error loading quiz: $e");
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
      _selectedOptionIndex = null;
      _feedbackColor = null;
      _remainingTime = 30;
      final currentQuestion = _quizQuestions[_currentQuestionIndex];
      _shuffledOptions = currentQuestion.options.values.toList()..shuffle();
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
        _goToNextQuestion();
      }
    });
  }

  void _checkAnswer(int selectedIndex, String selectedAnswer) {
    _timer?.cancel();
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final correctKey = currentQuestion.answer;
    final correctAnswerText = currentQuestion.options[correctKey];

    setState(() {
      _selectedOptionIndex = selectedIndex;
      if (selectedAnswer == correctAnswerText) {
        _feedbackColor = Colors.green;
        _score++;
        Provider.of<UserRepository>(context, listen: false).addCoins(10);
      } else {
        _feedbackColor = Colors.red;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _goToNextQuestion();
      }
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

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        _quizQuestions[_currentQuestionIndex].question,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _shuffledOptions.length,
                          itemBuilder: (context, index) {
                            Color? tileColor;
                            if (_selectedOptionIndex != null &&
                                _selectedOptionIndex == index) {
                              tileColor = _feedbackColor;
                            }

                            return Card(
                              color: tileColor,
                              child: ListTile(
                                title: Text(_shuffledOptions[index]),
                                onTap: _selectedOptionIndex == null
                                    ? () => _checkAnswer(
                                        index, _shuffledOptions[index])
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _goToNextQuestion,
                        child: const Text('سوال بعدی'),
                      ),
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
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: _remainingTime < 10 ? Colors.red : Colors.teal,
          child: Text(
            _remainingTime.toString(),
            style: const TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Text('$coins',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 4),
            const Icon(Icons.monetization_on, color: Colors.amber),
          ],
        ),
      ],
    );
  }
}
