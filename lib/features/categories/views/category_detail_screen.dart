import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:intl/intl.dart';

/// Tela de detalhes de uma categoria.
class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.onPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes da categoria ${category.name}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: category.displayColor.withValues(
                                alpha: 0.16,
                              ),
                              child: Icon(
                                Icons.category_rounded,
                                color: category.displayColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = constraints.maxWidth > 520
                                ? (constraints.maxWidth - 16) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildInfoRow(
                                  Icons.palette_outlined,
                                  'Cor',
                                  category.color,
                                  theme,
                                  itemWidth,
                                  iconColor: category.displayColor,
                                ),
                                _buildInfoRow(
                                  Icons.history_rounded,
                                  'Criada em',
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(category.createdAt),
                                  theme,
                                  itemWidth,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Monta uma linha de informação da categoria.
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
    double width, {
    Color? iconColor,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
