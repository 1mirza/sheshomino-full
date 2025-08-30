import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/farsi_content_model.dart';
import '../../../data/repositories/user_repository.dart';

class WordSpellingGameScreen extends StatefulWidget {
  final int lessonNumber;
  final String userName;

  const WordSpellingGameScreen({
    super.key,
    required this.lessonNumber,
    required this.userName,
  });

  @override
  State<WordSpellingGameScreen> createState() => _WordSpellingGameScreenState();
}

class _WordSpellingGameScreenState extends State<WordSpellingGameScreen> {
  Timer? _timer;
  int _remainingTime = 20;
  List<String> _allWords = [];
  List<String> _quizWords = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  String _wordWithBlank = '';
  String _missingLetter = '';
  List<String> _options = [];
  String? _selectedOption;
  bool _answered = false;

  // لیست حروف مهم املایی و گروه‌های هم‌آوا
  static const Map<String, List<String>> _trickyLetterGroups = {
    's': ['س', 'ص', 'ث'],
    'z': ['ز', 'ذ', 'ض', 'ظ'],
    't': ['ت', 'ط'],
    'h': ['ه', 'ح'],
    'gh': ['غ', 'ق'], // 'ق' برای چالش بیشتر اضافه شده
    'a': ['ا', 'ع'],
  };

  // لیست کامل حروف مهم برای فیلتر کردن کلمات
  static const List<String> _allTrickyLetters = [
    'ع',
    'غ',
    'س',
    'ث',
    'ص',
    'ط',
    'ت',
    'ظ',
    'ز',
    'ذ',
    'ض',
    'ح',
    'ه',
    'ق',
    'ا'
  ];

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
          .loadString('assets/json_data/farsi_json/emlaei.json');
      final List<dynamic> data = json.decode(response);

      final lessonData = data.firstWhere(
          (l) => l['lesson_number'] == widget.lessonNumber,
          orElse: () => null);

      if (lessonData != null) {
        final SpellingLesson lesson = SpellingLesson.fromJson(lessonData);
        // فیلتر کردن کلمات: فقط کلماتی که حروف مهم املایی دارند انتخاب می‌شوند
        _allWords = lesson.words
            .where((w) =>
                w.length > 2 &&
                w.split('').any((char) => _allTrickyLetters.contains(char)))
            .toList();
        _allWords.shuffle();
        _quizWords = _allWords.take(10).toList();

        if (_quizWords.isNotEmpty) {
          _setupNewQuestion();
        }
      }
    } catch (e) {
      print("Error loading spelling game: $e");
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

    final random = Random();
    final String fullWord = _quizWords[_currentQuestionIndex];

    // پیدا کردن تمام حروف املایی موجود در کلمه
    final List<int> trickyIndices = [];
    for (int i = 0; i < fullWord.length; i++) {
      if (_allTrickyLetters.contains(fullWord[i])) {
        trickyIndices.add(i);
      }
    }

    // اگر هیچ حرف چالشی پیدا نشد (که بعید است)، یک حرف تصادفی حذف کن
    if (trickyIndices.isEmpty) {
      // این حالت با توجه به فیلتر اولیه نباید رخ دهد
      // اما برای اطمینان کد آن باقی می‌ماند
      _setupRandomLetterQuestion(fullWord);
      return;
    }

    final int missingIndex =
        trickyIndices[random.nextInt(trickyIndices.length)];

    setState(() {
      _missingLetter = fullWord[missingIndex];
      _wordWithBlank = fullWord.substring(0, missingIndex) +
          ' _ ' +
          fullWord.substring(missingIndex + 1);

      // ساخت گزینه‌های هوشمند
      _options = _generateSmartOptions(_missingLetter);

      _remainingTime = 20;
      _answered = false;
      _selectedOption = null;
    });
    _startTimer();
  }

  // متد جدید برای ساخت گزینه‌های هوشمند
  List<String> _generateSmartOptions(String correctLetter) {
    final random = Random();
    List<String> options = [correctLetter];

    // پیدا کردن گروه هم‌آوا
    String? letterGroupKey;
    _trickyLetterGroups.forEach((key, value) {
      if (value.contains(correctLetter)) {
        letterGroupKey = key;
      }
    });

    if (letterGroupKey != null) {
      List<String> soundAlikes =
          List.from(_trickyLetterGroups[letterGroupKey]!);
      soundAlikes.remove(correctLetter);
      soundAlikes.shuffle();
      for (var letter in soundAlikes) {
        if (options.length < 4) {
          options.add(letter);
        }
      }
    }

    // اگر گزینه‌ها به ۴ تا نرسید، از حروف چالشی دیگر استفاده کن
    while (options.length < 4) {
      String randomLetter =
          _allTrickyLetters[random.nextInt(_allTrickyLetters.length)];
      if (!options.contains(randomLetter)) {
        options.add(randomLetter);
      }
    }

    options.shuffle();
    return options;
  }

  // متد پشتیبان برای کلماتی که حرف چالشی ندارند
  void _setupRandomLetterQuestion(String fullWord) {
    final random = Random();
    final int missingIndex = random.nextInt(fullWord.length);
    setState(() {
      _missingLetter = fullWord[missingIndex];
      _wordWithBlank = fullWord.substring(0, missingIndex) +
          ' _ ' +
          fullWord.substring(missingIndex + 1);

      const String alphabet = 'ابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی';
      _options = [_missingLetter];
      while (_options.length < 4) {
        String randomLetter = alphabet[random.nextInt(alphabet.length)];
        if (!_options.contains(randomLetter)) {
          _options.add(randomLetter);
        }
      }
      _options.shuffle();

      _remainingTime = 20;
      _answered = false;
      _selectedOption = null;
    });
    _startTimer();
  }

  void _checkAnswer(String selectedLetter) {
    if (_answered) return;

    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = selectedLetter;
    });

    final userRepo = Provider.of<UserRepository>(context, listen: false);

    if (selectedLetter == _missingLetter) {
      setState(() {
        _score++;
        userRepo.addCoins(10);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('آفرین! حرف درست بود.'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('اشتباه بود! حرف صحیح: "$_missingLetter"'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حرف صحیح: "$_missingLetter" بود.'),
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
          title: const Text('بازی کامل کردن کلمات'),
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
                ? const Center(
                    child: Text('کلمه‌ی مناسبی برای این درس یافت نشد.'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeader(widget.userName, userCoins),
                        const SizedBox(height: 20),
                        _buildQuestionCard(),
                        const SizedBox(height: 30),
                        _buildOptionsButtons(),
                        const Spacer(),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'حرف جا افتاده در کلمه‌ی زیر چیست؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              _wordWithBlank,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _options.map((letter) {
        Color? buttonColor;
        if (_answered) {
          if (letter == _missingLetter) {
            buttonColor = Colors.green;
          } else if (letter == _selectedOption) {
            buttonColor = Colors.red;
          }
        }

        return ElevatedButton(
          onPressed: _answered ? null : () => _checkAnswer(letter),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            minimumSize: const Size(80, 60),
            textStyle:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          child: Text(letter),
        );
      }).toList(),
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
          title: const Text('پایان بازی!'),
          content: Text('امتیاز شما: $_score از ۱۰'),
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
          backgroundColor: _remainingTime < 6 ? Colors.red : Colors.teal,
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
