import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

class ActivityRepository with ChangeNotifier {
  List<QuizResult> _quizResults = [];
  final Map<String, List<UsageSession>> _usageSessions = {};
  UsageSession? _currentSession;

  List<QuizResult> get quizResults => _quizResults;

  ActivityRepository() {
    loadActivities();
  }

  Future<void> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? resultsJson = prefs.getString('quiz_results');
    if (resultsJson != null) {
      final List<dynamic> decoded = json.decode(resultsJson);
      _quizResults = decoded.map((e) => QuizResult.fromJson(e)).toList();
    }
    // Load usage sessions
    final String? sessionsJson = prefs.getString('usage_sessions');
    if (sessionsJson != null) {
      final Map<String, dynamic> decoded = json.decode(sessionsJson);
      decoded.forEach((key, value) {
        final List<dynamic> sessionsList = value;
        _usageSessions[key] =
            sessionsList.map((e) => UsageSession.fromJson(e)).toList();
      });
    }
    notifyListeners();
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    // Save quiz results
    final String resultsJson =
        json.encode(_quizResults.map((e) => e.toJson()).toList());
    await prefs.setString('quiz_results', resultsJson);
    // Save usage sessions
    final Map<String, dynamic> sessionsToSave = {};
    _usageSessions.forEach((key, value) {
      sessionsToSave[key] = value.map((e) => e.toJson()).toList();
    });
    final String sessionsJson = json.encode(sessionsToSave);
    await prefs.setString('usage_sessions', sessionsJson);
  }

  void addQuizResult(QuizResult result) {
    _quizResults.insert(0, result); // Add to the beginning of the list
    _saveActivities();
    notifyListeners();
  }

  void startTracking(String subject) {
    _currentSession = UsageSession(
      subject: subject,
      startTime: DateTime.now(),
      endTime: DateTime.now(), // Will be updated
    );
  }

  void stopTracking() {
    if (_currentSession == null) return;
    _currentSession!.endTime = DateTime.now();

    if (!_usageSessions.containsKey(_currentSession!.subject)) {
      _usageSessions[_currentSession!.subject] = [];
    }
    _usageSessions[_currentSession!.subject]!.add(_currentSession!);
    _currentSession = null;
    _saveActivities();
    notifyListeners();
  }

  Map<String, Duration> getUsageStats() {
    final Map<String, Duration> stats = {};
    _usageSessions.forEach((subject, sessions) {
      Duration totalDuration = Duration.zero;
      for (var session in sessions) {
        totalDuration += session.duration;
      }
      stats[subject] = totalDuration;
    });
    return stats;
  }

  Duration getTotalUsageToday() {
    Duration totalDuration = Duration.zero;
    final now = DateTime.now();
    _usageSessions.forEach((subject, sessions) {
      for (var session in sessions) {
        if (session.startTime.year == now.year &&
            session.startTime.month == now.month &&
            session.startTime.day == now.day) {
          totalDuration += session.duration;
        }
      }
    });
    return totalDuration;
  }
}
