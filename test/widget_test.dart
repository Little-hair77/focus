import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';

void main() {
  testWidgets('footer exibe navegação para categorias', (tester) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Categorias'), findsOneWidget);

    await tester.tap(find.text('Categorias'));
    await tester.pump();

    expect(selectedIndex, 2);
  });
}
