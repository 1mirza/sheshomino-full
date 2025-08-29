import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/farsi_content_model.dart';

// این کلاس مانند یک موتور هوشمند برای مدیریت تمام داده‌های کتاب فارسی عمل می‌کند
class FarsiBookRepository {
  // Singleton: این الگو تضمین می‌کند که فقط یک نمونه از این کلاس در کل برنامه وجود دارد
  FarsiBookRepository._privateConstructor();
  static final FarsiBookRepository instance =
      FarsiBookRepository._privateConstructor();

  // حافظه موقت برای نگهداری داده‌های بارگذاری شده
  Map<String, int> _titleToLessonNumberMap = {};
  Map<String, dynamic>? _meaningfulData;
  Map<String, dynamic>? _familyData;
  Map<String, dynamic>? _antonymData; // داده جدید برای متضادها
  bool _isInitialized = false;

  // این تابع در اولین استفاده، تمام فایل‌های جیسون را بارگذاری و نقشه هوشمند را می‌سازد
  Future<void> init() async {
    if (_isInitialized) return;

    // بارگذاری فایل‌های راهنما برای ساخت نقشه
    final emlaei = json.decode(
        await rootBundle.loadString('assets/json_data/farsi_json/emlaei.json'));
    final negaresh = json.decode(await rootBundle
        .loadString('assets/json_data/farsi_json/negaresh.json'));

    // ساخت نقشه از emlaei.json
    for (var lesson in emlaei) {
      _titleToLessonNumberMap[_normalizeTitle(lesson['lesson_title'])] =
          lesson['lesson_number'];
    }
    // ساخت نقشه از negaresh.json (این کار باعث می‌شود تمام تنوع‌های نوشتاری پوشش داده شود)
    for (var chapter in negaresh['chapters']) {
      for (var lesson in chapter['lessons']) {
        _titleToLessonNumberMap[_normalizeTitle(lesson['lesson_title'])] =
            lesson['lesson_number'];
      }
    }
    _titleToLessonNumberMap[_normalizeTitle("معرفت آفریدگار")] = 1;

    // بارگذاری فایل‌های محتوا
    _meaningfulData = json.decode(await rootBundle
        .loadString('assets/json_data/farsi_json/meaningfull.json'));
    _familyData = json.decode(await rootBundle
        .loadString('assets/json_data/farsi_json/hamkhanevadeh.json'));
    _antonymData = json.decode(await rootBundle
        .loadString('assets/json_data/farsi_json/motazad.json'));

    _isInitialized = true;
  }

  // این تابع عنوان‌ها را یکسان‌سازی می‌کند تا تفاوت‌های جزئی نادیده گرفته شوند
  String _normalizeTitle(String title) {
    return title
        .replaceAll(' ', '')
        .replaceAll('‌', '') // حذف نیم‌فاصله
        .replaceAll('ي', 'ی') // تبدیل ی عربی به فارسی
        .replaceAll('ك', 'ک'); // تبدیل ک عربی به فارسی
  }

  // تابع عمومی برای گرفتن لیست معنی کلمات یک درس خاص
  Future<List<WordMeaning>> getMeaningsForLesson(String lessonTitle) async {
    await init();
    final lessonNumber = _titleToLessonNumberMap[_normalizeTitle(lessonTitle)];
    if (lessonNumber == null || _meaningfulData == null) return [];

    final List<dynamic> lessons = _meaningfulData!['lessons'];
    final lessonData = lessons.firstWhere(
        (l) => l['lesson_number'] == lessonNumber,
        orElse: () => null);

    if (lessonData != null) {
      return WordMeaningLesson.fromJson(lessonData).words;
    }
    return [];
  }

  // تابع عمومی برای گرفتن لیست کلمات هم‌خانواده یک درس خاص
  Future<List<WordFamily>> getFamiliesForLesson(String lessonTitle) async {
    await init();
    final lessonNumber = _titleToLessonNumberMap[_normalizeTitle(lessonTitle)];
    if (lessonNumber == null || _familyData == null) return [];

    final List<dynamic> lessons = _familyData!['lessons'];
    final lessonData = lessons.firstWhere(
        (l) => l['lesson_number'] == lessonNumber,
        orElse: () => null);

    if (lessonData != null) {
      return WordFamilyLesson.fromJson(lessonData).families;
    }
    return [];
  }

  // <<<<< متد فراموش شده برای گرفتن کلمات متضاد اضافه شد >>>>>
  Future<List<WordMeaning>> getAntonymsForLesson(String lessonTitle) async {
    await init();
    final lessonNumber = _titleToLessonNumberMap[_normalizeTitle(lessonTitle)];
    if (lessonNumber == null || _antonymData == null) return [];

    final List<dynamic> lessons = _antonymData!['lessons'];
    final lessonData = lessons.firstWhere(
        (l) => l['lesson_number'] == lessonNumber,
        orElse: () => null);

    if (lessonData != null) {
      // ما از همان مدل WordMeaningLesson استفاده می‌کنیم چون ساختار جیسون یکی است
      return WordMeaningLesson.fromJson(lessonData).words;
    }
    return [];
  }
}
