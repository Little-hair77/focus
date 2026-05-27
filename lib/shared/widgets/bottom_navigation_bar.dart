import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: isDark
          ? AppColors.darkTextHighEmphasis
          : theme.colorScheme.primary,
      unselectedItemColor: isDark
          ? AppColors.darkTextMediumEmphasis
          : AppColors.textMediumEmphasis,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist_rounded),
          label: 'Tarefas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categorias'
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.archive),
          label: 'Lixeira',
        ),
      ],
    );
  }
}
