class UserProfile {
  String name;
  int coins;
  int rank;
  List<String> purchasedAvatars; // لیستی از آواتارهای خریداری شده

  UserProfile({
    required this.name,
    this.coins = 100, // سکه اولیه کاربر
    this.rank = 1,
    this.purchasedAvatars = const [],
  });

  // متدهایی برای تبدیل داده به جیسون و برعکس (برای ذخیره‌سازی)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'coins': coins,
      'rank': rank,
      'purchasedAvatars': purchasedAvatars,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      coins: json['coins'],
      rank: json['rank'],
      purchasedAvatars: List<String>.from(json['purchasedAvatars']),
    );
  }
}
