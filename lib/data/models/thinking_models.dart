// این فایل ساختار داده‌ای محتوای کتاب تفکر و پژوهش را تعریف می‌کند

// مدل برای یک اسلاید جزوه یا یک فعالیت
class ContentSlide {
  final int number;
  final String title;
  final String content;

  ContentSlide(
      {required this.number, required this.title, required this.content});

  factory ContentSlide.fromJson(Map<String, dynamic> json, String numberKey) {
    return ContentSlide(
      number: json[numberKey],
      title: json['title'],
      content: json['content'] ?? json['question'] ?? '',
    );
  }
}

// مدل برای یک درس کامل از نوع جزوه یا فعالیت
class ContentLesson {
  final String title;
  final List<ContentSlide> slides;

  ContentLesson({required this.title, required this.slides});

  factory ContentLesson.fromJson(
      Map<String, dynamic> json, String contentKey, String numberKey) {
    var contentList = json[contentKey] as List? ?? [];
    List<ContentSlide> parsedSlides =
        contentList.map((s) => ContentSlide.fromJson(s, numberKey)).toList();
    return ContentLesson(
      title: json['title'],
      slides: parsedSlides,
    );
  }
}

// مدل برای یک سوال آزمون
class ThinkingQuizQuestion {
  final int id;
  final String question;
  final Map<String, String> options;
  final String answer;

  ThinkingQuizQuestion(
      {required this.id,
      required this.question,
      required this.options,
      required this.answer});

  factory ThinkingQuizQuestion.fromJson(Map<String, dynamic> json) {
    final Map<String, String> castedOptions = (json['options'] as Map).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    return ThinkingQuizQuestion(
      id: json['id'],
      question: json['question'],
      options: castedOptions,
      answer: json['answer'],
    );
  }
}

// مدل برای یک درس کامل آزمون
class ThinkingQuizLesson {
  final String title;
  final List<ThinkingQuizQuestion> questions;

  ThinkingQuizLesson({
    required this.title,
    required this.questions,
  });

  factory ThinkingQuizLesson.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    List<ThinkingQuizQuestion> parsedQuestions =
        questionsList.map((q) => ThinkingQuizQuestion.fromJson(q)).toList();
    return ThinkingQuizLesson(
      title: json['title'],
      questions: parsedQuestions,
    );
  }
}
