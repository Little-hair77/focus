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
    final handleTap = onTap ?? (index) => _navigate(context, index);

    return Stack(
      children: [
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: handleTap,
          selectedItemColor: isDark
              ? AppColors.darkTextHighEmphasis
              : theme.colorScheme.primary,
          unselectedItemColor: isDark
              ? AppColors.darkTextMediumEmphasis
              : AppColors.textMediumEmphasis,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rounded),
              label: 'Tarefas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categorias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete_outline),
              label: 'Lixeira',
            ),
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.25,
              heightFactor: 1,
              child: _TrashDropTarget(
                onAccept: onTrashDrop,
                onTap: () => handleTap(3),
              ),
            ),
          ),
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
  final VoidCallback onTap;

  const _TrashDropTarget({this.onAccept, required this.onTap});

  @override
  State<_TrashDropTarget> createState() => _TrashDropTargetState();
}

class _TrashDropTargetState extends State<_TrashDropTarget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TrashDragData>(
      key: const ValueKey('trash-drop-target'),
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
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: _isHovering
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
        );
      },
    );
  }
}
