// این فایل ساختار داده‌ای مربوط به جزوه‌های ریاضی را تعریف می‌کند

class MathSlide {
  final int slideNumber;
  final String title;
  final String content;

  MathSlide({
    required this.slideNumber,
    required this.title,
    required this.content,
  });

  factory MathSlide.fromJson(Map<String, dynamic> json) {
    return MathSlide(
      slideNumber: json['slide_number'],
      title: json['title'],
      content: json['content'],
    );
  }
}

// ***** کلاس فراموش شده در اینجا اضافه شد *****
class MathLesson {
  final int lessonNumber;
  final String title;
  final List<MathSlide> slides;

  MathLesson({
    required this.lessonNumber,
    required this.title,
    required this.slides,
  });

  factory MathLesson.fromJson(Map<String, dynamic> json) {
    var slidesList = json['slides'] as List;
    List<MathSlide> parsedSlides =
        slidesList.map((s) => MathSlide.fromJson(s)).toList();
    return MathLesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      slides: parsedSlides,
    );
  }
}
