import 'package:flutter/material.dart';

const appTabRoutes = ['/home', '/tasks', '/categories', '/trash'];

void navigateToTab(BuildContext context, int currentIndex, int nextIndex) {
  if (nextIndex == currentIndex ||
      nextIndex < 0 ||
      nextIndex >= appTabRoutes.length) {
    return;
  }

  Navigator.of(context).pushReplacementNamed(appTabRoutes[nextIndex]);
}
