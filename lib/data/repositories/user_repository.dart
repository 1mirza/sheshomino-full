import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result_model.dart';
import '../models/user_profile_model.dart';

// این کلاس با ChangeNotifier ترکیب شده تا بتواند تغییرات را به UI اطلاع دهد
class UserRepository with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  // این متد در ابتدای برنامه فراخوانی می‌شود تا اطلاعات کاربر را از حافظه بخواند
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(json.decode(profileJson));
      notifyListeners(); // به ویجت‌ها اطلاع بده که داده‌ها بارگذاری شد
    }
  }

  // این متد اطلاعات جدید پروفایل را در حافظه ذخیره می‌کند
  Future<void> _saveProfile() async {
    if (_userProfile == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String profileJson = json.encode(_userProfile!.toJson());
    await prefs.setString('user_profile', profileJson);
  }

  // برای ساخت پروفایل جدید هنگام ثبت‌نام
  void createNewProfile(String name) {
    _userProfile = UserProfile(name: name);
    _saveProfile();
    notifyListeners();
  }

  // برای اضافه کردن سکه (مثلاً بعد از جواب درست یا دیدن تبلیغ)
  void addCoins(int amount) {
    if (_userProfile == null) return;
    _userProfile!.coins += amount;
    _saveProfile();
    notifyListeners(); // به UI اطلاع بده که تعداد سکه‌ها تغییر کرده
  }

  // برای کم کردن سکه (مثلاً برای راهنمایی یا خرید از فروشگاه)
  bool useCoins(int amount) {
    if (_userProfile == null || _userProfile!.coins < amount) {
      return false; // سکه کافی نیست
    }
    _userProfile!.coins -= amount;
    _saveProfile();
    notifyListeners();
    return true; // موفقیت‌آمیز بود
  }

  // متد جدید برای افزودن نتیجه آزمون
  void addQuizResult(QuizResult result) {
    if (_userProfile == null) return;
    // آزمون جدید را به ابتدای لیست اضافه می‌کنیم تا جدیدترین‌ها بالاتر باشند
    _userProfile!.quizHistory.insert(0, result);
    _saveProfile();
    notifyListeners();
  }
}
