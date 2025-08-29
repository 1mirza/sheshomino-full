import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/farsi_content_model.dart';
import '../../../data/repositories/user_repository.dart';

class WordMeaningGameScreen extends StatefulWidget {
  final int lessonNumber;
  final String userName;

  const WordMeaningGameScreen({
    super.key,
    required this.lessonNumber,
    required this.userName,
  });

  @override
  State<WordMeaningGameScreen> createState() => _WordMeaningGameScreenState();
}

class _WordMeaningGameScreenState extends State<WordMeaningGameScreen> {
  Timer? _timer;
  int _remainingTime = 30;
  List<WordMeaning> _allWords = [];
  List<WordMeaning> _quizWords = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  String _currentAnswer = '';
  List<String> _userInput = [];
  List<String> _keyboardLetters = [];

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
          .loadString('assets/json_data/farsi_json/meaningfull.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> lessons = data['lessons'];

      final lessonData = lessons.firstWhere(
          (l) => l['lesson_number'] == widget.lessonNumber,
          orElse: () => null);

      if (lessonData != null) {
        final WordMeaningLesson lesson = WordMeaningLesson.fromJson(lessonData);
        _allWords = lesson.words;
        _allWords.shuffle();
        _quizWords = _allWords.take(10).toList();

        if (_quizWords.isNotEmpty) {
          _setupNewQuestion();
        }
      }
    } catch (e) {
      print("Error loading game: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setupNewQuestion() {
    if (_currentQuestionIndex >= _quizWords.length) {
      _showResultDialog();
      return;
    }

    setState(() {
      _currentAnswer =
          _quizWords[_currentQuestionIndex].meaning.replaceAll(' ', '');
      _userInput = List.generate(_currentAnswer.length, (index) => '');
      _keyboardLetters = _generateKeyboardLetters(_currentAnswer);
      _remainingTime = 30;
    });
    _startTimer();
  }

  void _checkAnswer() {
    if (_userInput.join('') == _currentAnswer) {
      final userRepo = Provider.of<UserRepository>(context, listen: false);
      _timer?.cancel();
      setState(() {
        _score++;
        userRepo.addCoins(10);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('آفرین! پاسخ درست بود.'),
            backgroundColor: Colors.green),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _currentQuestionIndex++;
          _setupNewQuestion();
        });
      });
    }
  }

  void _showHint() {
    final userRepo = Provider.of<UserRepository>(context, listen: false);
    if (userRepo.useCoins(20)) {
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('راهنمایی'),
            content: Text('پاسخ صحیح: $_currentAnswer'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('فهمیدم'))
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('سکه کافی نداری!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepo = Provider.of<UserRepository>(context);
    final userCoins = userRepo.userProfile?.coins ?? 0;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بازی معنی کلمات'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onBackPressed()) Navigator.of(context).pop();
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quizWords.isEmpty
                ? const Center(child: Text('کلمه‌ای برای این درس یافت نشد.'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeader(widget.userName, userCoins),
                        const SizedBox(height: 20),
                        _buildQuestionCard(),
                        const SizedBox(height: 15),
                        Container(
                          height: 50,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Center(child: Text('محل نمایش تبلیغات')),
                        ),
                        const SizedBox(height: 20),
                        _buildAnswerBoxes(),
                        const Spacer(),
                        _buildKeyboard(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ... (کدهای دیگر که تغییری نکرده‌اند برای اختصار حذف شده‌اند)
  List<String> _generateKeyboardLetters(String answer) {
    List<String> letters = answer.split('');
    const String alphabet = 'ابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی';
    Random random = Random();
    while (letters.length < 16) {
      letters.add(alphabet[random.nextInt(alphabet.length)]);
    }
    letters.shuffle();
    return letters;
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
        _showAnswerAndProceed();
      }
    });
  }

  void _showAnswerAndProceed({bool fromButton = false}) {
    if (!mounted) return;
    _timer?.cancel();
    setState(() {
      _userInput = _currentAnswer.split('');
    });

    Future.delayed(Duration(seconds: fromButton ? 5 : 2), () {
      if (!mounted) return;
      setState(() {
        _currentQuestionIndex++;
        _setupNewQuestion();
      });
    });
  }

  void _onLetterSelected(String letter) {
    final firstEmptyIndex = _userInput.indexWhere((char) => char == '');
    if (firstEmptyIndex != -1) {
      setState(() {
        _userInput[firstEmptyIndex] = letter;
      });
    }

    if (!_userInput.contains('')) {
      _checkAnswer();
    }
  }

  void _onDeleteLetter() {
    final lastFilledIndex = _userInput.lastIndexWhere((char) => char != '');
    if (lastFilledIndex != -1) {
      setState(() {
        _userInput[lastFilledIndex] = '';
      });
    }
  }

  void _showResultDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('پایان بازی!'),
          content: Text('امتیاز شما: $_score از ۱۰'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
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
          title: const Text('خروج از بازی'),
          content: const Text(
              'آیا می‌خواهید از بازی خارج شوید؟ پیشرفت شما ذخیره نخواهد شد.'),
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

  Widget _buildQuestionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'معنی کلمه‌ی "${_quizWords[_currentQuestionIndex].word}" چیست؟',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAnswerBoxes() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(_currentAnswer.length, (index) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _userInput.length > index ? _userInput[index] : '',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKeyboard() {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: _keyboardLetters.length + 1,
        itemBuilder: (context, index) {
          if (index == _keyboardLetters.length) {
            return ElevatedButton(
              onPressed: _onDeleteLetter,
              child: const Icon(Icons.backspace_outlined),
            );
          }
          final letter = _keyboardLetters[index];
          return ElevatedButton(
            onPressed: () => _onLetterSelected(letter),
            child: Text(letter, style: const TextStyle(fontSize: 18)),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _showHint,
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('راهنمایی (۲۰ سکه)'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAnswerAndProceed(fromButton: true),
          icon: const Icon(Icons.skip_next_outlined),
          label: const Text('سوال بعدی'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
        ),
      ],
    );
  }
}
