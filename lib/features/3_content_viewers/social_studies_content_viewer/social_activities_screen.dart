import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sheshomino/widgets/app_background.dart';
import 'package:sheshomino/widgets/glass_card.dart';
import '../../../config/theme/responsive_sizer.dart';
import '../../../data/repositories/user_repository.dart';

// Models for this specific screen
class Activity {
  final int activityNumber;
  final String question;
  final String answer;

  Activity(
      {required this.activityNumber,
      required this.question,
      required this.answer});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityNumber: json['activity_number'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}

class ActivitiesLesson {
  final int lessonNumber;
  final String title;
  final List<Activity> activities;

  ActivitiesLesson(
      {required this.lessonNumber,
      required this.title,
      required this.activities});

  factory ActivitiesLesson.fromJson(Map<String, dynamic> json) {
    var activitiesList = json['activities'] as List? ?? [];
    List<Activity> parsedActivities =
        activitiesList.map((a) => Activity.fromJson(a)).toList();
    return ActivitiesLesson(
      lessonNumber: json['lesson_number'],
      title: json['title'],
      activities: parsedActivities,
    );
  }
}

class SocialActivitiesScreen extends StatefulWidget {
  final String screenTitle;
  final int chapterNumber;
  final int lessonNumber;
  final String userName;

  const SocialActivitiesScreen({
    super.key,
    required this.screenTitle,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.userName,
  });

  @override
  State<SocialActivitiesScreen> createState() => _SocialActivitiesScreenState();
}

class _SocialActivitiesScreenState extends State<SocialActivitiesScreen> {
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final String response = await rootBundle.loadString(
          'assets/json_data/json_ejtemae/social_studies_activities.json');
      final List<dynamic> data = json.decode(response);
      final chapterData = data.firstWhere(
          (d) => d['chapter_number'] == widget.chapterNumber,
          orElse: () => null);

      if (chapterData != null) {
        final lessonData = (chapterData['lessons'] as List).firstWhere(
            (l) => l['lesson_number'] == widget.lessonNumber,
            orElse: () => null);

        if (lessonData != null) {
          final ActivitiesLesson lesson = ActivitiesLesson.fromJson(lessonData);
          _activities = lesson.activities;
        }
      }
    } catch (e) {
      print("Error loading activities: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSizer.init(context);
    final userRepo = Provider.of<UserRepository>(context);
    final userCoins = userRepo.userProfile?.coins ?? 0;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.screenTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activities.isEmpty
                ? const Center(child: Text('فعالیتی برای این درس یافت نشد.'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeader(widget.userName, userCoins),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _activities.length,
                            itemBuilder: (context, index) {
                              final activity = _activities[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GlassCard(
                                  child: ExpansionTile(
                                    title: Text(
                                      activity.question,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ResponsiveSizer.sp(15),
                                          color: Colors.black87),
                                    ),
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          activity.answer,
                                          style: TextStyle(
                                              fontSize: ResponsiveSizer.sp(14),
                                              color: Colors.black
                                                  .withOpacity(0.7)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader(String name, int coins) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(),
            const SizedBox(width: 8),
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveSizer.sp(14),
                    color: Colors.white)),
          ],
        ),
        Row(
          children: [
            Text('$coins',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveSizer.sp(16),
                    color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.monetization_on, color: Colors.amber),
          ],
        ),
      ],
    );
  }
}
