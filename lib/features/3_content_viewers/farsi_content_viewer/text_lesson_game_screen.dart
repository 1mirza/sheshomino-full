import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/farsi_content_model.dart';
import '../../../data/repositories/user_repository.dart';

class TextLessonGameScreen extends StatefulWidget {
  final int lessonNumber;
  final String userName;

  const TextLessonGameScreen({
    super.key,
    required this.lessonNumber,
    required this.userName,
  });

  @override
  State<TextLessonGameScreen> createState() => _TextLessonGameScreenState();
}

class _TextLessonGameScreenState extends State<TextLessonGameScreen> {
  Timer? _timer;
  int _remainingTime = 30;
  List<TextQuestion> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  String? _selectedOption;
  bool _answered = false;

  // <<<<< اصلاحیه: لیستی برای نگهداری گزینه‌های به هم ریخته >>>>>
  List<String> _currentOptions = [];

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
          .loadString('assets/json_data/farsi_json/matndars.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> lessons = data['lessons'];

      final lessonData = lessons.firstWhere(
          (l) => l['lesson_number'] == widget.lessonNumber,
          orElse: () => null);

      if (lessonData != null) {
        final TextLesson lesson = TextLesson.fromJson(lessonData);
        _quizQuestions = lesson.questions;
        _quizQuestions.shuffle();

        if (_quizQuestions.isNotEmpty) {
          _setupNewQuestion();
        }
      }
    } catch (e) {
      print("Error loading text lesson game: $e");
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
      _showResultDialog();
      return;
    }
    setState(() {
      _remainingTime = 30;
      _answered = false;
      _selectedOption = null;
      // <<<<< اصلاحیه: گزینه‌ها فقط یک بار در اینجا به هم ریخته و ذخیره می‌شوند >>>>>
      _currentOptions = _quizQuestions[_currentQuestionIndex]
          .options
          .values
          .toList()
        ..shuffle();
    });
    _startTimer();
  }

  void _checkAnswer(String selectedOption) {
    if (_answered) return;

    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = selectedOption;
    });

    final userRepo = Provider.of<UserRepository>(context, listen: false);
    final correctAnswer = _quizQuestions[_currentQuestionIndex].correctAnswer;

    if (selectedOption == correctAnswer) {
      setState(() {
        _score++;
        userRepo.addCoins(10);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('آفرین! پاسخ درست بود.'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('اشتباه بود! پاسخ صحیح: "$correctAnswer"'),
            backgroundColor: Colors.red),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _currentQuestionIndex++;
        _setupNewQuestion();
      });
    });
  }

  void _skipQuestion() {
    _timer?.cancel();
    final correctAnswer = _quizQuestions[_currentQuestionIndex].correctAnswer;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('پاسخ صحیح: "$correctAnswer" بود.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _currentQuestionIndex++;
        _setupNewQuestion();
      });
    });
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
        _skipQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRepo = Provider.of<UserRepository>(context);
    final userCoins = userRepo.userProfile?.coins ?? 0;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('آزمون متن درس'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quizQuestions.isEmpty
                ? const Center(
                    child: Text('سؤالی برای این درس یافت نشد.'),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeader(widget.userName, userCoins),
                        const SizedBox(height: 20),
                        _buildQuestionCard(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _buildOptionsList(),
                        ),
                        ElevatedButton.icon(
                          onPressed: _answered ? null : _skipQuestion,
                          icon: const Icon(Icons.skip_next_outlined),
                          label: const Text('سوال بعدی'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          _quizQuestions[_currentQuestionIndex].question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    final question = _quizQuestions[_currentQuestionIndex];
    // <<<<< اصلاحیه: از لیست گزینه‌هایی که قبلا به هم ریخته شده استفاده می‌کنیم >>>>>
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
            title: Text(option),
            onTap: _answered ? null : () => _checkAnswer(option),
            trailing: trailingIcon,
          ),
        );
      },
    );
  }

  void _showResultDialog() {
    _timer?.cancel();
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

  Future<bool> _onBackPressed() async {
    _timer?.cancel();
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
