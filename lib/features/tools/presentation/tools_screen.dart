import 'package:azan_app/core/widgets/section_header.dart';
import 'package:azan_app/core/widgets/tool_item.dart';
import 'package:azan_app/features/azkar/presentation/azkar_screen.dart';
import 'package:azan_app/features/tools/presentation/puzzle_screen.dart';
import 'package:azan_app/features/tools/presentation/puzzle2_screen.dart';
import 'package:azan_app/features/tools/presentation/quiz_screen.dart';
import 'package:azan_app/features/tasbih/presentation/tasbih_screen.dart';
import 'package:flutter/material.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
      children: <Widget>[
        const SectionHeader(
          title: 'Tools',
          padding: EdgeInsets.only(bottom: 14),
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.12,
          children: <Widget>[
            ToolItem(
              icon: Icons.touch_app_rounded,
              label: 'Tasbih',
              onTap: () => _open(context, const TasbihScreen()),
            ),
            ToolItem(
              icon: Icons.menu_book_rounded,
              label: 'Duas',
              onTap: () => _open(context, const AzkarScreen()),
            ),
            ToolItem(
              icon: Icons.quiz_outlined,
              label: 'Quiz',
              onTap: () => _open(context, const QuizScreen()),
            ),
            ToolItem(
              icon: Icons.extension_outlined,
              label: 'Puzzle',
              onTap: () => _open(context, const PuzzleScreen()),
            ),
            ToolItem(
              icon: Icons.grid_view_rounded,
              label: 'Islamic Puzzle 2',
              onTap: () => _open(context, const Puzzle2Screen()),
            ),
          ],
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }
}
