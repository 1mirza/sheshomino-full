import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/activity_repository.dart';

class MyActivitiesScreen extends StatelessWidget {
  const MyActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the repository using Provider
    final activityRepo = Provider.of<ActivityRepository>(context);
    final usageStats = activityRepo.getUsageStats();
    final quizResults = activityRepo.quizResults;
    final totalDurationToday = activityRepo.getTotalUsageToday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('فعالیت‌های من'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total study time card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'مجموع مطالعه امروز',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDuration(totalDurationToday),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Study time distribution chart card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'زمان مطالعه (به تفکیک درس)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    usageStats.isEmpty
                        ? const Text('هنوز فعالیتی ثبت نشده است.')
                        : SizedBox(
                            height: 200,
                            child: _buildUsagePieChart(context, usageStats),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quiz results and chart card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'نتایج آزمون‌ها',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    quizResults.isEmpty
                        ? const Text('هنوز آزمونی ثبت نشده است.')
                        : SizedBox(
                            height: 200,
                            child: _buildScoresBarChart(context, quizResults),
                          ),
                    const SizedBox(height: 20),
                    _buildQuizResultList(quizResults),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format duration to a readable string
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Widget to build the usage pie chart
  Widget _buildUsagePieChart(
      BuildContext context, Map<String, Duration> usageStats) {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
    ];
    int colorIndex = 0;

    usageStats.forEach((subject, duration) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: duration.inSeconds.toDouble(),
          title: subject,
          radius: 80,
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  // Widget to build the scores bar chart
  Widget _buildScoresBarChart(
      BuildContext context, List<QuizResult> quizResults) {
    final Map<String, List<double>> scoresBySubject = {};
    for (var result in quizResults) {
      if (!scoresBySubject.containsKey(result.subject)) {
        scoresBySubject[result.subject] = [];
      }
      scoresBySubject[result.subject]!
          .add((result.score / result.totalQuestions) * 100);
    }

    final List<BarChartGroupData> barGroups = [];
    int x = 0;
    scoresBySubject.forEach((subject, scores) {
      final double average = scores.reduce((a, b) => a + b) / scores.length;
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: average,
              color: Theme.of(context).primaryColor,
              width: 16,
            ),
          ],
        ),
      );
      x++;
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final subjects = scoresBySubject.keys.toList();
                if (value.toInt() < subjects.length) {
                  return Text(subjects[value.toInt()],
                      style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  // Widget to build the list of quiz results
  Widget _buildQuizResultList(List<QuizResult> quizResults) {
    if (quizResults.isEmpty) {
      return const SizedBox
          .shrink(); // Return an empty widget if there are no results
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizResults.length,
          itemBuilder: (context, index) {
            final result = quizResults[index];
            final formattedDate =
                intl.DateFormat('yyyy/MM/dd – HH:mm').format(result.date);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${result.score}/${result.totalQuestions}'),
                ),
                title: Text('${result.subject}: ${result.lessonTitle}'),
                subtitle: Text(formattedDate),
              ),
            );
          },
        ),
      ],
    );
  }
}
