import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
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

  testWidgets('lixeira aceita tarefa em toda a área do item de navegação', (
    tester,
  ) async {
    TrashDragData? acceptedData;
    const dragData = TrashDragData(id: 'task-1', type: TrashItemType.task);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const Align(
            alignment: Alignment.topLeft,
            child: LongPressDraggable<TrashDragData>(
              data: dragData,
              feedback: SizedBox(width: 40, height: 40),
              child: SizedBox(
                key: ValueKey('draggable-task'),
                width: 100,
                height: 60,
                child: ColoredBox(color: Colors.blue),
              ),
            ),
          ),
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: 1,
            onTap: (_) {},
            onTrashDrop: (data) => acceptedData = data,
          ),
        ),
      ),
    );

    final targetFinder = find.byKey(const ValueKey('trash-drop-target'));
    final targetRect = tester.getRect(targetFinder);

    expect(targetRect.width, greaterThan(80));
    expect(targetRect.height, greaterThan(40));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('draggable-task'))),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(targetRect.center);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(acceptedData, dragData);
  });
}
