class TechnologyQuizLesson {
  final int lessonNumber;
  final List<TechnologyQuizQuestion> questions;

  TechnologyQuizLesson({required this.lessonNumber, required this.questions});

  factory TechnologyQuizLesson.fromJson(Map<String, dynamic> json) {
    var questionsFromJson = json['questions'] as List;
    List<TechnologyQuizQuestion> questionList = questionsFromJson
        .map((i) => TechnologyQuizQuestion.fromJson(i))
        .toList();
    return TechnologyQuizLesson(
      lessonNumber: json['lesson_number'],
      questions: questionList,
    );
  }
}

class TechnologyQuizQuestion {
  final String question; // Was questionText
  final List<String> options;
  final String answer; // Was correctAnswer

  TechnologyQuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory TechnologyQuizQuestion.fromJson(Map<String, dynamic> json) {
    // Handling both Map<String, String> and List<String> for options
    List<String> optionsList;
    if (json['options'] is Map) {
      optionsList = (json['options'] as Map<String, dynamic>)
          .values
          .map((e) => e.toString())
          .toList();
    } else {
      optionsList = List<String>.from(json['options']);
    }

    return TechnologyQuizQuestion(
      question: json['question'],
      options: optionsList,
      answer: json['correct_answer'],
    );
  }
}
