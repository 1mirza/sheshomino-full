import 'quiz_result_model.dart';

class UserProfile {
  String name;
  int coins;
  int rank;
  List<String> purchasedAvatars;
  List<QuizResult> quizHistory;

  // <<<<< شروع اصلاحیه >>>>>
  // سازنده را تغییر دادیم تا همیشه لیست‌های قابل رشد ایجاد کند
  UserProfile({
    required this.name,
    this.coins = 100,
    this.rank = 1,
    List<String>? purchasedAvatars,
    List<QuizResult>? quizHistory,
  })  : this.purchasedAvatars = purchasedAvatars ?? [],
        this.quizHistory = quizHistory ?? [];
  // <<<<< پایان اصلاحیه >>>>>

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'coins': coins,
      'rank': rank,
      'purchasedAvatars': purchasedAvatars,
      'quizHistory': quizHistory.map((e) => e.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'کاربر مهمان',
      coins: json['coins'] ?? 100,
      rank: json['rank'] ?? 1,
      purchasedAvatars: List<String>.from(json['purchasedAvatars'] ?? []),
      quizHistory: (json['quizHistory'] as List<dynamic>?)
              ?.map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
