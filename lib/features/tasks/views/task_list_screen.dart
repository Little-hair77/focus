import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/features/tasks/views/task_form_screen.dart';
import 'package:focus/features/tasks/widgets/category_task_section.dart';
import 'package:focus/features/tasks/widgets/task_card.dart';
import 'package:focus/features/tasks/widgets/task_empty_state.dart';
import 'package:focus/features/tasks/widgets/task_filter_bar.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:provider/provider.dart';

/// Tela de listagem, filtro e agrupamento de tarefas.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

/// Estado local dos filtros aplicados à lista de tarefas.
class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  DateTime? _dueDateFilter;
  bool _showByCategory = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);
    final categoriesById = {
      for (final category in categoryVM.categories) category.id: category,
    };
    final filteredTasks = _filterTasks(taskVM.tasks);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return AppGestureNavigation(
      tabIndex: 1,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const AppDrawer(),
        appBar: const AppBarWidget(),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: 1,
          onTrashDrop: (data) => _moveToTrash(context, data, taskVM),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Minhas Tarefas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              TaskFilterBar(
                searchController: _searchController,
                selectedDueDate: _dueDateFilter,
                showByCategory: _showByCategory,
                onSearchChanged: (_) => setState(() {}),
                onPickDueDate: _pickDueDate,
                onClearDueDate: () => setState(() => _dueDateFilter = null),
                onShowByCategoryChanged: (value) =>
                    setState(() => _showByCategory = value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: taskVM.isLoading
                    ? _buildLoadingState(theme)
                    : taskVM.tasks.isEmpty
                    ? const TaskEmptyState()
                    : filteredTasks.isEmpty
                    ? const TaskNoResultsState()
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: _showByCategory
                              ? _buildCategorizedTaskList(
                                  filteredTasks,
                                  categoriesById,
                                  taskVM,
                                  isWideScreen,
                                  screenWidth,
                                )
                              : _buildTaskList(
                                  filteredTasks,
                                  categoriesById,
                                  taskVM,
                                  isWideScreen,
                                  screenWidth,
                                ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'Adicionar nova tarefa',
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskFormScreen()),
            );
          },
          label: const Text(
            'Nova Tarefa',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.add, color: AppColors.onPrimary),
        ),
      ),
    );
  }

  /// Abre o seletor de data usado pelo filtro de vencimento.
  Future<void> _pickDueDate() async {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDateFilter ?? today,
      firstDate: DateTime(today.year - 5),
      lastDate: DateTime(today.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.colorScheme.primary,
              brightness: theme.brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDateFilter = picked);
    }
  }

  /// Aplica busca textual e filtro por vencimento.
  List<Task> _filterTasks(List<Task> tasks) {
    final query = _searchController.text.trim().toLowerCase();

    return tasks.where((task) {
      final matchesTitle =
          query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesDueDate =
          _dueDateFilter == null ||
          (task.dueDate != null && _isSameDay(task.dueDate!, _dueDateFilter!));

      return matchesTitle && matchesDueDate;
    }).toList();
  }

  /// Monta a lista simples de tarefas.
  Widget _buildTaskList(
    List<Task> tasks,
    Map<String, Category> categoriesById,
    TaskViewModel taskVM,
    bool isWideScreen,
    double screenWidth,
  ) {
    if (isWideScreen) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 900 ? 3 : 2,
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
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => TaskCard(
        task: tasks[index],
        taskVM: taskVM,
        categoriesById: categoriesById,
      ),
    );
  }

  /// Monta a lista agrupada por categoria.
  Widget _buildCategorizedTaskList(
    List<Task> tasks,
    Map<String, Category> categoriesById,
    TaskViewModel taskVM,
    bool isWideScreen,
    double screenWidth,
  ) {
    final groupedTasks = <String?, List<Task>>{};
    for (final task in tasks) {
      final categoryKey = categoriesById.containsKey(task.categoryId)
          ? task.categoryId
          : null;
      groupedTasks.putIfAbsent(categoryKey, () => []).add(task);
    }

    final orderedKeys = groupedTasks.keys.toList()
      ..sort((a, b) {
        final aName = categoriesById[a]?.name ?? 'Sem categoria';
        final bName = categoriesById[b]?.name ?? 'Sem categoria';
        return aName.toLowerCase().compareTo(bName.toLowerCase());
      });

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: orderedKeys.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final categoryId = orderedKeys[index];
        final category = categoriesById[categoryId];

        return CategoryTaskSection(
          title: category?.name ?? 'Sem categoria',
          color: category?.displayColor ?? AppColors.textMuted,
          tasks: groupedTasks[categoryId]!,
          taskVM: taskVM,
          categoriesById: categoriesById,
          isWideScreen: isWideScreen,
          screenWidth: screenWidth,
        );
      },
    );
  }

  /// Monta o estado de carregamento da lista.
  Widget _buildLoadingState(ThemeData theme) {
    return Semantics(
      label: 'Carregando tarefas',
      liveRegion: true,
      child: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );
  }

  /// Move uma tarefa arrastada para a lixeira.
  Future<void> _moveToTrash(
    BuildContext context,
    TrashDragData data,
    TaskViewModel taskVM,
  ) async {
    if (data.type != TrashItemType.task) return;
    await taskVM.removeTask(data.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa movida para a lixeira.')),
    );
  }

  /// Compara duas datas ignorando horário.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
