import 'package:flutter/material.dart';

const appTabRoutes = ['/home', '/tasks', '/categories', '/trash'];

/// Navega entre abas usando o índice atual e o próximo índice.
void navigateToTab(BuildContext context, int currentIndex, int nextIndex) {
  if (nextIndex == currentIndex ||
      nextIndex < 0 ||
      nextIndex >= appTabRoutes.length) {
    return;
  }

  Navigator.of(context).pushReplacementNamed(appTabRoutes[nextIndex]);
}
