class SocialContentSlide {
  final int number;
  final String title;
  final String content;

  SocialContentSlide(
      {required this.number, required this.title, required this.content});

  factory SocialContentSlide.fromJson(
      Map<String, dynamic> json, String numberKey) {
    return SocialContentSlide(
      number: json[numberKey],
      title: json['title'],
      content: json['content'],
    );
  }
}

class SocialContentLesson {
  final int lessonNumber;
  final String title;
  final List<SocialContentSlide> slides;

  SocialContentLesson(
      {required this.lessonNumber, required this.title, required this.slides});

  factory SocialContentLesson.fromJson(
      Map<String, dynamic> json, String contentKey, String numberKey) {
    var contentList = json[contentKey] as List? ?? [];
    List<SocialContentSlide> parsedSlides = contentList
        .map((s) => SocialContentSlide.fromJson(s, numberKey))
        .toList();
    return SocialContentLesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      slides: parsedSlides,
    );
  }
}

class SocialQuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  SocialQuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory SocialQuizQuestion.fromJson(Map<String, dynamic> json) {
    return SocialQuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}

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
