import 'package:flutter/material.dart';
import '../../3_content_viewers/lesson_viewer/lesson_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final String name;
  const HomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    // ... (بخش appBar و body بدون تغییر)
    // ...
    // فقط بخش GridView را با کد زیر جایگزین کنید

    return Scaffold(
      appBar: AppBar(
        title: Text('سلام $name، خوش اومدی!'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildBookCard(
                  context,
                  title: 'کتاب ریاضی',
                  icon: Icons.calculate,
                  color: Colors.orange,
                  onTap: () => _navigateToLessons(context, 'دروس ریاضی',
                      'assets/json_data/mathdarslist.json'),
                ),
                _buildBookCard(
                  context,
                  title: 'کتاب فارسی',
                  icon: Icons.book_outlined,
                  color: Colors.red,
                  onTap: () => _navigateToLessons(context, 'دروس فارسی',
                      'assets/json_data/farsidarslist.json'),
                ),
                _buildBookCard(
                  context,
                  title: 'کتاب علوم',
                  icon: Icons.science_outlined,
                  color: Colors.green,
                  onTap: () => _navigateToLessons(context, 'دروس علوم',
                      'assets/json_data/oloumdarslist.json'),
                ),
                _buildBookCard(
                  context,
                  title: 'کتاب اجتماعی',
                  icon: Icons.public,
                  color: Colors.blue,
                  onTap: () => _navigateToLessons(context, 'دروس اجتماعی',
                      'assets/json_data/ejtemaedarslist.json'),
                ),
                _buildBookCard(
                  context,
                  title: 'تفکر و پژوهش',
                  icon: Icons.psychology_outlined,
                  color: Colors.purple,
                  onTap: () => _navigateToLessons(context, 'دروس تفکر و پژوهش',
                      'assets/json_data/tafakordarslist.json'),
                ),
                _buildBookCard(
                  context,
                  title: 'کار و فناوری',
                  icon: Icons.computer,
                  color: Colors.brown,
                  onTap: () => _navigateToLessons(context, 'دروس کار و فناوری',
                      'assets/json_data/fanavaridarslist.json'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMyActivitiesButton(context),
          ],
        ),
      ),
    );
  }

  // متد کمکی برای جلوگیری از تکرار کد
  void _navigateToLessons(BuildContext context, String title, String jsonPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonListScreen(
          bookTitle: title,
          jsonPath: jsonPath,
        ),
      ),
    );
  }

  // ... (متدهای _buildBookCard و _buildMyActivitiesButton بدون تغییر باقی می‌مانند)
  Widget _buildBookCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyActivitiesButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        print('فعالیت‌های من کلیک شد');
      },
      icon: const Icon(Icons.person_outline),
      label: const Text(
        'فعالیت‌های من',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
