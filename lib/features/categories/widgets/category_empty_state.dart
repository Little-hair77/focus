import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';

/// Estado vazio quando não há categorias cadastradas.
class CategoryEmptyState extends StatelessWidget {
  const CategoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.category_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma categoria cadastrada.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
