import 'package:flutter/material.dart';
import '../../../../data/models/quiz_result_model.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;

  const QuizResultScreen({super.key, required this.result});

  // ویجت کمکی برای ساختن ردیف‌های پاسخ به صورت یکسان
  Widget _buildAnswerRow(BuildContext context, String label, String answer,
      Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: answer,
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نتایج آزمون: ${result.lessonTitle}'),
        // دکمه بازگشت پیش‌فرض را حذف می‌کند تا کاربر از دکمه طراحی شده استفاده کند
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // کارت خلاصه نتایج در بالا
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      '${result.bookTitle} - ${result.lessonTitle}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'امتیاز شما',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${result.score} از ${result.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // عنوان بخش بررسی سوالات
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'بررسی سوالات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(indent: 16, endIndent: 16, thickness: 1),
          // لیست سوالات و پاسخ‌ها
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: result.results.length,
              itemBuilder: (context, index) {
                final questionResult = result.results[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // متن سوال
                        Text(
                          '${index + 1}. ${questionResult.question}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // پاسخ شما
                        _buildAnswerRow(
                          context,
                          'پاسخ شما: ',
                          questionResult.selectedAnswer,
                          questionResult.isCorrect ? Colors.green : Colors.red,
                          questionResult.isCorrect
                              ? Icons.check_circle
                              : Icons.cancel,
                        ),
                        const SizedBox(height: 8),
                        // پاسخ صحیح (فقط در صورتی که پاسخ شما غلط باشد نمایش داده می‌شود)
                        if (!questionResult.isCorrect)
                          _buildAnswerRow(
                            context,
                            'پاسخ صحیح: ',
                            questionResult.correctAnswer,
                            Colors.green,
                            Icons.check_circle_outline,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // دکمه بازگشت به منوی درس
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // دو بار به عقب برمی‌گردد تا به صفحه‌ی منوی درس برسد (صفحه‌ی آزمون را رد می‌کند)
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
              child: const Text('بازگشت به منوی درس'),
            ),
          ),
        ],
      ),
    );
  }
}
