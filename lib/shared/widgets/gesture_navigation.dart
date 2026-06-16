import 'package:flutter/material.dart';
import 'package:focus/shared/utils/navigation.dart';

class AppGestureNavigation extends StatelessWidget {
  final Widget child;
  final int? tabIndex;
  final bool enableBackGesture;

  const AppGestureNavigation({
    super.key,
    required this.child,
    this.tabIndex,
    this.enableBackGesture = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) => _handleHorizontalDrag(context, details),
      child: child,
    );
  }

  void _handleHorizontalDrag(BuildContext context, DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 360) return;

    if (tabIndex != null) {
      final nextIndex = velocity < 0 ? tabIndex! + 1 : tabIndex! - 1;
      navigateToTab(context, tabIndex!, nextIndex);
      return;
    }

    if (enableBackGesture && velocity > 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
