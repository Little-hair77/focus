import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/shared/models/trash_drag_data.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final ValueChanged<TrashDragData>? onTrashDrop;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onTrashDrop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap ?? (index) => _navigate(context, index),
      selectedItemColor: isDark
          ? AppColors.darkTextHighEmphasis
          : theme.colorScheme.primary,
      unselectedItemColor: isDark
          ? AppColors.darkTextMediumEmphasis
          : AppColors.textMediumEmphasis,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.checklist_rounded),
          label: 'Tarefas',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categorias',
        ),
        BottomNavigationBarItem(
          icon: _TrashDropTarget(onAccept: onTrashDrop),
          label: 'Lixeira',
        ),
      ],
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    const routes = ['/home', '/tasks', '/categories', '/trash'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }
}

class _TrashDropTarget extends StatefulWidget {
  final ValueChanged<TrashDragData>? onAccept;

  const _TrashDropTarget({this.onAccept});

  @override
  State<_TrashDropTarget> createState() => _TrashDropTargetState();
}

class _TrashDropTargetState extends State<_TrashDropTarget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TrashDragData>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isHovering = true);
        return widget.onAccept != null;
      },
      onLeave: (_) => setState(() => _isHovering = false),
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        widget.onAccept?.call(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovering ? 1.35 : 1,
          child: Icon(
            _isHovering ? Icons.delete_forever : Icons.delete_outline,
          ),
        );
      },
    );
  }
}
