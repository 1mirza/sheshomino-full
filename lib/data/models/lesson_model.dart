// این مدل برای مدیریت ساختارهای مختلف جیسون طراحی شده است

class Chapter {
  final int? chapterNumber; // شماره فصل می‌تواند وجود نداشته باشد
  final String chapterTitle;
  final List<Lesson> lessons;

  Chapter({
    this.chapterNumber,
    required this.chapterTitle,
    required this.lessons,
  });

  // این متد یک نقشه (Map) از جیسون را به یک شیء Chapter تبدیل می‌کند
  factory Chapter.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List;
    List<Lesson> parsedLessons =
        lessonsList.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();

    return Chapter(
      // هوشمندانه شماره فصل را از کلیدهای مختلف می‌خواند
      chapterNumber: json['chapter_number'] ?? json['section_number'],
      // هوشمندانه عنوان فصل را از کلیدهای مختلف می‌خواند
      chapterTitle: json['chapter_title'] ?? json['section_title'] ?? 'فصل',
      lessons: parsedLessons,
    );
  }
}

class Lesson {
  final int? lessonNumber; // شماره درس می‌تواند وجود نداشته باشد
  final String title;
  final String? type;
  final bool isElective; // فیلد جدید برای دروس اختیاری

  Lesson({
    this.lessonNumber,
    required this.title,
    this.type,
    this.isElective = false, // مقدار پیش‌فرض false است
  });

  // این متد یک نقشه (Map) از جیسون را به یک شیء Lesson تبدیل می‌کند
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      type: json['type'],
      isElective: json['is_elective'] ?? false,
    );
  }
}
