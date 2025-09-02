class QuizResult {
  final String subject;
  final String lessonTitle;
  final int score;
  final int totalQuestions;
  final DateTime date;

  QuizResult({
    required this.subject,
    required this.lessonTitle,
    required this.score,
    required this.totalQuestions,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'lessonTitle': lessonTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': date.toIso8601String(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      subject: json['subject'],
      lessonTitle: json['lessonTitle'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      date: DateTime.parse(json['date']),
    );
  }
}

// <<<<< شروع بخش اضافه شده >>>>>
class UsageSession {
  final String subject;
  DateTime startTime;
  DateTime endTime;

  UsageSession({
    required this.subject,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory UsageSession.fromJson(Map<String, dynamic> json) {
    return UsageSession(
      subject: json['subject'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }
}
// <<<<< پایان بخش اضافه شده >>>>>
