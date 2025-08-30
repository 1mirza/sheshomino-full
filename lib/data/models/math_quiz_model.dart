class MathQuizQuestion {
  final int questionNumber;
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  MathQuizQuestion({
    required this.questionNumber,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  // **تغییر اصلی اینجاست**
  // این تابع حالا مقاوم‌تر شده و در صورت نبود داده، مقادیر پیش‌فرض را برمی‌گرداند
  factory MathQuizQuestion.fromJson(Map<String, dynamic> json) {
    return MathQuizQuestion(
      questionNumber: json['question_number'] ?? 0,
      questionText: json['question_text'] ?? 'متن سوال یافت نشد',
      options:
          json['options'] != null ? List<String>.from(json['options']) : [],
      correctAnswer: json['correct_answer'] ?? '',
    );
  }
}

class MathQuizLesson {
  final int lessonNumber;
  final String title;
  final List<MathQuizQuestion> questions;

  MathQuizLesson({
    required this.lessonNumber,
    required this.title,
    required this.questions,
  });

  // **تغییر اصلی اینجاست**
  factory MathQuizLesson.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    List<MathQuizQuestion> parsedQuestions =
        questionsList.map((q) => MathQuizQuestion.fromJson(q)).toList();
    return MathQuizLesson(
      lessonNumber: json['lesson_number'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      questions: parsedQuestions,
    );
  }
}
