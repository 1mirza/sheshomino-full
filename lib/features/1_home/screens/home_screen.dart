import 'package:flutter/material.dart';
import 'package:sheshomino/features/2_quiz/screens/my_activities_screen.dart';
import '../../3_content_viewers/lesson_viewer/lesson_list_screen.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  final String name;
  const HomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
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
                    icon: Icons.calculate_rounded,
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
                ],
              ),
              const SizedBox(height: 24),
              _buildMyActivitiesButton(context),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildBookCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return _HoverableGlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyActivitiesButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyActivitiesScreen()),
        );
      },
      icon: const Icon(Icons.history_edu_rounded),
      label: const Text('فعالیت‌های من'),
    );
  }
}

// ویجت کمکی برای مدیریت حالت هاور و انیمیشن کارت‌های شیشه‌ای
class _HoverableGlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverableGlassCard({required this.child, required this.onTap});

  @override
  __HoverableGlassCardState createState() => __HoverableGlassCardState();
}

class __HoverableGlassCardState extends State<_HoverableGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final transform =
        _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: transform,
          transformAlignment: Alignment.center,
          child: GlassCard(
              padding: const EdgeInsets.all(8.0), child: widget.child),
        ),
      ),
    );
  }
}
