// مدل برای یک اسلاید یا یک آزمایش
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
      content: json['content'],
    );
  }
}

// مدل برای یک درس کامل از نوع جزوه یا آزمایش
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
class ScienceQuizQuestion {
  final int id;
  final String question;
  final Map<String, String> options;
  final String answer;

  ScienceQuizQuestion(
      {required this.id,
      required this.question,
      required this.options,
      required this.answer});

  factory ScienceQuizQuestion.fromJson(Map<String, dynamic> json) {
    final Map<String, String> castedOptions = (json['options'] as Map).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    return ScienceQuizQuestion(
      id: json['id'],
      question: json['question'],
      options: castedOptions,
      answer: json['answer'],
    );
  }
}

// مدل برای یک درس کامل آزمون
class ScienceQuizLesson {
  final int lessonNumber;
  final String title;
  final List<ScienceQuizQuestion> questions;

  ScienceQuizLesson({
    required this.lessonNumber,
    required this.title,
    required this.questions,
  });

  factory ScienceQuizLesson.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    List<ScienceQuizQuestion> parsedQuestions =
        questionsList.map((q) => ScienceQuizQuestion.fromJson(q)).toList();
    return ScienceQuizLesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      questions: parsedQuestions,
    );
  }
}
