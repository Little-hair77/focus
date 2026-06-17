import 'package:flutter/material.dart';
import 'package:focus/shared/widgets/app_input_decoration.dart';
import 'package:intl/intl.dart';

/// Barra de filtros da tela de tarefas.
class TaskFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final DateTime? selectedDueDate;
  final bool showByCategory;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onPickDueDate;
  final VoidCallback onClearDueDate;
  final ValueChanged<bool> onShowByCategoryChanged;

  const TaskFilterBar({
    super.key,
    required this.searchController,
    required this.selectedDueDate,
    required this.showByCategory,
    required this.onSearchChanged,
    required this.onPickDueDate,
    required this.onClearDueDate,
    required this.onShowByCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueDateLabel = selectedDueDate == null
        ? 'Vencimento'
        : DateFormat('dd/MM/yyyy').format(selectedDueDate!);

    return LayoutBuilder(
      builder: (context, constraints) {
        final searchWidth = constraints.maxWidth < 420
            ? constraints.maxWidth
            : 420.0;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: searchWidth,
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration:
                    appInputDecoration(
                      context,
                      label: 'Buscar atividade',
                      icon: Icons.search_rounded,
                    ).copyWith(
                      suffixIcon: searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpar busca',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                searchController.clear();
                                onSearchChanged('');
                              },
                            ),
                    ),
              ),
            ),
            InputChip(
              avatar: Icon(
                Icons.event_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: Text(dueDateLabel),
              onPressed: onPickDueDate,
              onDeleted: selectedDueDate == null ? null : onClearDueDate,
              deleteIcon: const Icon(Icons.close_rounded, size: 18),
            ),
            FilterChip(
              avatar: Icon(
                Icons.category_rounded,
                color: showByCategory
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Exibir por categoria'),
              selected: showByCategory,
              onSelected: onShowByCategoryChanged,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
              labelStyle: TextStyle(
                color: showByCategory
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
