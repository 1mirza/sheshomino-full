import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/social_models.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/repositories/user_repository.dart';

class SocialQuizScreen extends StatefulWidget {
  final int chapterNumber;
  final int lessonNumber;
  final String lessonTitle;
  final String userName;

  const SocialQuizScreen({
    super.key,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.lessonTitle,
    required this.userName,
  });

  @override
  State<SocialQuizScreen> createState() => _SocialQuizScreenState();
}

class _SocialQuizScreenState extends State<SocialQuizScreen> {
  List<SocialQuizQuestion> _allQuestions = [];
  List<SocialQuizQuestion> _quizQuestions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _remainingTime = 30;
  String? _selectedOption;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
    Provider.of<ActivityRepository>(context, listen: false)
        .startTracking('اجتماعی');
  }

  @override
  void dispose() {
    _timer?.cancel();
    Provider.of<ActivityRepository>(context, listen: false).stopTracking();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final String response = await rootBundle.loadString(
          'assets/json_data/json_ejtemaei/social_studies_quiz.json');
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
          final SocialQuizLesson lesson = SocialQuizLesson.fromJson(lessonData);
          _allQuestions = lesson.questions;
          _allQuestions.shuffle();
          _quizQuestions = _allQuestions.take(10).toList();
        }
      }
    } catch (e) {
      print("Error loading social studies quiz: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (_quizQuestions.isNotEmpty) {
          _startTimer();
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTime = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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

  void _checkAnswer(String option) {
    if (_answered) return;

    final userRepo = Provider.of<UserRepository>(context, listen: false);
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = option;
      if (option == _quizQuestions[_currentQuestionIndex].answer) {
        _score++;
        userRepo.addCoins(10);
      }
    });

    Future.delayed(const Duration(seconds: 0), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _answered = false;
      });
      _startTimer();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    _timer?.cancel();
    final activityRepo =
        Provider.of<ActivityRepository>(context, listen: false);
    final result = QuizResult(
      subject: 'اجتماعی',
      lessonTitle: widget.lessonTitle,
      score: _score,
      totalQuestions: _quizQuestions.length,
      date: DateTime.now(),
    );
    activityRepo.addQuizResult(result);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
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
        );
      },
    );
  }

  Color _getOptionColor(String option) {
    if (!_answered) {
      return Colors.grey.shade200;
    }
    if (option == _quizQuestions[_currentQuestionIndex].answer) {
      return Colors.green.shade200;
    }
    if (option == _selectedOption) {
      return Colors.red.shade200;
    }
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSizer.init(context);
    final userRepo = Provider.of<UserRepository>(context);
    final userCoins = userRepo.userProfile?.coins ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("آزمون: ${widget.lessonTitle}"),
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
                      Expanded(
                        child: ListView(
                          children: _buildOptions(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: _answered ? _nextQuestion : null,
                          child: const Text("سوال بعدی")),
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

  List<Widget> _buildOptions() {
    final question = _quizQuestions[_currentQuestionIndex];
    // <<<<< اصلاحیه: استفاده از question.options.values >>>>>
    List<String> options = List.from(question.options.values);

    return options.map((option) {
      return Card(
        color: _getOptionColor(option),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: InkWell(
          onTap: _answered ? null : () => _checkAnswer(option),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              option,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: ResponsiveSizer.sp(15)),
            ),
          ),
        ),
      );
    }).toList();
  }
}
