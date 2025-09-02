// این فایل ساختار داده‌ای محتوای کتاب مطالعات اجتماعی را تعریف می‌کند

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
      title:
          json['title'] ?? json['question'] ?? 'بدون عنوان', // هوشمندسازی عنوان
      content: json['content'] ?? json['answer'] ?? '', // هوشمندسازی محتوا
    );
  }
}

// مدل برای یک درس کامل از نوع جزوه یا فعالیت
class ContentLesson {
  final int lessonNumber;
  final String title;
  final List<ContentSlide> slides;

  ContentLesson(
      {required this.lessonNumber, required this.title, required this.slides});

  factory ContentLesson.fromJson(
      Map<String, dynamic> json, String contentKey, String numberKey) {
    var contentList = json[contentKey] as List? ?? [];
    List<ContentSlide> parsedSlides =
        contentList.map((s) => ContentSlide.fromJson(s, numberKey)).toList();
    return ContentLesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      slides: parsedSlides,
    );
  }
}

// مدل برای یک سوال آزمون
class SocialQuizQuestion {
  final int id;
  final String question;
  final Map<String, String> options;
  final String answer;

  SocialQuizQuestion(
      {required this.id,
      required this.question,
      required this.options,
      required this.answer});

  factory SocialQuizQuestion.fromJson(Map<String, dynamic> json) {
    final Map<String, String> castedOptions = (json['options'] as Map).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    return SocialQuizQuestion(
      id: json['id'],
      question: json['question'],
      options: castedOptions,
      answer: json['answer'],
    );
  }
}

// مدل برای یک درس کامل آزمون
class SocialQuizLesson {
  final int lessonNumber;
  final String title;
  final List<SocialQuizQuestion> questions;

  SocialQuizLesson({
    required this.lessonNumber,
    required this.title,
    required this.questions,
  });

  factory SocialQuizLesson.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    List<SocialQuizQuestion> parsedQuestions =
        questionsList.map((q) => SocialQuizQuestion.fromJson(q)).toList();
    return SocialQuizLesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      questions: parsedQuestions,
    );
  }
}
