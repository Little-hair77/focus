import 'package:flutter/material.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/features/tasks/widgets/task_card.dart';

/// Seção de tarefas agrupadas por categoria.
class CategoryTaskSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Task> tasks;
  final TaskViewModel taskVM;
  final Map<String, Category> categoriesById;
  final bool isWideScreen;
  final double screenWidth;

  const CategoryTaskSection({
    super.key,
    required this.title,
    required this.color,
    required this.tasks,
    required this.taskVM,
    required this.categoriesById,
    required this.isWideScreen,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = screenWidth > 900 ? 3 : 2;
    final rowCount = (tasks.length / columnCount).ceil();
    final gridHeight = rowCount * 100 + (rowCount - 1) * 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$title (${tasks.length})',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (isWideScreen)
          SizedBox(
            height: gridHeight.toDouble(),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 100,
              ),
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskCard(
                task: tasks[index],
                taskVM: taskVM,
                categoriesById: categoriesById,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => TaskCard(
              task: tasks[index],
              taskVM: taskVM,
              categoriesById: categoriesById,
            ),
          ),
      ],
    );
  }
}
