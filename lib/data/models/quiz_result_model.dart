// این فایل ساختار داده‌ای نتایج آزمون را برای ذخیره‌سازی و نمایش تعریف می‌کند.

// کلاس برای نگهداری نتیجه‌ی یک سوال خاص در آزمون
class QuestionResult {
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionResult({
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  // متد برای تبدیل شی به نقشه (Map) جهت ذخیره‌سازی در جیسون
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
    };
  }

  // متد برای ساخت یک شی از روی نقشه (Map) جیسون
  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      question: json['question'],
      selectedAnswer: json['selectedAnswer'],
      correctAnswer: json['correctAnswer'],
      isCorrect: json['isCorrect'],
    );
  }
}

// کلاس برای نگهداری نتیجه‌ی کامل یک آزمون
class QuizResult {
  final String bookTitle;
  final String lessonTitle;
  final int score;
  final int totalQuestions;
  final DateTime date;
  final List<QuestionResult> results; // لیستی از نتایج تک‌تک سوالات

  QuizResult({
    required this.bookTitle,
    required this.lessonTitle,
    required this.score,
    required this.totalQuestions,
    required this.date,
    required this.results,
  });

  // متد برای تبدیل شی به نقشه (Map) جهت ذخیره‌سازی در جیسون
  Map<String, dynamic> toJson() {
    return {
      'bookTitle': bookTitle,
      'lessonTitle': lessonTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'date':
          date.toIso8601String(), // تاریخ به فرمت استاندارد رشته تبدیل می‌شود
      'results': results
          .map((r) => r.toJson())
          .toList(), // لیست نتایج هم به جیسون تبدیل می‌شود
    };
  }

  // متد برای ساخت یک شی از روی نقشه (Map) جیسون
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    var resultsList = json['results'] as List;
    List<QuestionResult> parsedResults =
        resultsList.map((r) => QuestionResult.fromJson(r)).toList();

    return QuizResult(
      bookTitle: json['bookTitle'],
      lessonTitle: json['lessonTitle'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      date: DateTime.parse(
          json['date']), // رشته تاریخ دوباره به شی DateTime تبدیل می‌شود
      results: parsedResults,
    );
  }
}
