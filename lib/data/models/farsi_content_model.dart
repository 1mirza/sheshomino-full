// این فایل ساختار داده‌ای محتوای دروس فارسی را تعریف می‌کند

// مدل برای معنی کلمات و کلمات متضاد
class WordMeaning {
  final String word;
  final String meaning;

  WordMeaning({required this.word, required this.meaning});

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    // هوشمندانه معنی یا متضاد را می‌خواند
    return WordMeaning(
      word: json['word'],
      meaning: json['meaning'] ?? json['antonym'],
    );
  }
}

class WordMeaningLesson {
  final int lessonNumber;
  final List<WordMeaning> words;

  WordMeaningLesson({required this.lessonNumber, required this.words});

  factory WordMeaningLesson.fromJson(Map<String, dynamic> json) {
    var wordsList = json['words'] as List;
    List<WordMeaning> parsedWords =
        wordsList.map((w) => WordMeaning.fromJson(w)).toList();
    return WordMeaningLesson(
      lessonNumber: json['lesson_number'],
      words: parsedWords,
    );
  }
}

// مدل برای کلمات هم خانواده
class WordFamily {
  final List<String> words;

  WordFamily({required this.words});

  factory WordFamily.fromJson(List<dynamic> json) {
    return WordFamily(
      words: json.map((e) => e.toString()).toList(),
    );
  }
}

class WordFamilyLesson {
  final int lessonNumber;
  final List<WordFamily> families;

  WordFamilyLesson({required this.lessonNumber, required this.families});

  factory WordFamilyLesson.fromJson(Map<String, dynamic> json) {
    var familiesList = json['word_families'] as List;
    List<WordFamily> parsedFamilies =
        familiesList.map((f) => WordFamily.fromJson(f)).toList();
    return WordFamilyLesson(
      lessonNumber: json['lesson_number'],
      families: parsedFamilies,
    );
  }
}

// مدل برای کلمات مهم املایی
class SpellingLesson {
  final int lessonNumber;
  final List<String> words;

  SpellingLesson({required this.lessonNumber, required this.words});

  factory SpellingLesson.fromJson(Map<String, dynamic> json) {
    return SpellingLesson(
      lessonNumber: json['lesson_number'],
      words: List<String>.from(json['words']),
    );
  }
}

// <<<<< شروع بخش اصلاح شده >>>>>
// مدل برای سوالات متن درس
class TextQuestion {
  final int id;
  final String question;
  final Map<String, String> options;
  final String correctAnswerKey;

  TextQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerKey,
  });

  // یک متد کمکی برای دسترسی آسان به متن پاسخ صحیح
  String get correctAnswer {
    // A trick to find the correct answer text from its key ('الف', 'ب', etc.)
    final correctOptionEntry = options.entries
        .firstWhere((entry) => entry.key.startsWith(correctAnswerKey));
    return correctOptionEntry.value;
  }

  factory TextQuestion.fromJson(Map<String, dynamic> json) {
    // تبدیل گزینه‌ها از جیسون به یک نقشه قابل استفاده
    final Map<String, String> parsedOptions = {};
    (json['options'] as Map).forEach((key, value) {
      parsedOptions[key.toString()] = value.toString();
    });

    return TextQuestion(
      id: json['id'],
      question: json['question'],
      options: parsedOptions,
      correctAnswerKey: json['answer'],
    );
  }
}

// این کلاس فراموش شده بود و اکنون اضافه شد
class TextLesson {
  final int lessonNumber;
  final String lessonTitle;
  final List<TextQuestion> questions;

  TextLesson({
    required this.lessonNumber,
    required this.lessonTitle,
    required this.questions,
  });

  factory TextLesson.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<TextQuestion> parsedQuestions =
        questionsList.map((q) => TextQuestion.fromJson(q)).toList();
    return TextLesson(
      lessonNumber: json['lesson_number'],
      lessonTitle: json['lesson_title'],
      questions: parsedQuestions,
    );
  }
}
// <<<<< پایان بخش اصلاح شده >>>>>

// مدل برای سوالات نگارش
class NegareshQuestion {
  final int questionNumber;
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  NegareshQuestion({
    required this.questionNumber,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  factory NegareshQuestion.fromJson(Map<String, dynamic> json) {
    return NegareshQuestion(
      questionNumber: json['question_number'],
      questionText: json['question_text'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
    );
  }
}

class NegareshLesson {
  final int lessonNumber;
  final String lessonTitle;
  final List<NegareshQuestion> questions;

  NegareshLesson({
    required this.lessonNumber,
    required this.lessonTitle,
    required this.questions,
  });

  factory NegareshLesson.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<NegareshQuestion> parsedQuestions =
        questionsList.map((q) => NegareshQuestion.fromJson(q)).toList();
    return NegareshLesson(
      lessonNumber: json['lesson_number'],
      lessonTitle: json['lesson_title'],
      questions: parsedQuestions,
    );
  }
}
