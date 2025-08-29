// این فایل ساختار داده‌ای محتوای دروس فارسی را تعریف می‌کند

// مدل برای معنی کلمات و کلمات متضاد
class WordMeaning {
  final String word;
  final String meaning;

  WordMeaning({required this.word, required this.meaning});

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
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

// <<<<< شروع کد جدید >>>>>
// مدل برای کلمات هم خانواده
class WordFamily {
  final List<String> words;

  WordFamily({required this.words});

  factory WordFamily.fromJson(List<dynamic> json) {
    // تبدیل لیست جیسون به لیست رشته‌ها
    return WordFamily(
      words: json.map((e) => e.toString()).toList(),
    );
  }
}

// این کلاس یک درس کامل از نوع "هم خانواده" را نگهداری می‌کند
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
// <<<<< پایان کد جدید >>>>>
