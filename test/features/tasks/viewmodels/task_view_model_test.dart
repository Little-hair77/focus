import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:focus/data/repositories/task_repository.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';

//Mock assinando o contrato
class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late TaskViewModel viewModel;
  late MockTaskRepository mockRepository;
  final dummyTask = Task(
    id: '1',
    title: 'Estudar Testes no Flutter',
    description: 'Sprint 3 do app Focus',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(dummyTask);
  });

  // O setUp roda antes de cada teste, garantindo um ambiente limpo
  setUp(() {
    mockRepository = MockTaskRepository();
    viewModel = TaskViewModel(mockRepository);
  });

  group('TaskViewModel - Testes Unitários', () {
    test(
      'Deve inicializar com a lista de tarefas vazia e isLoading como false',
      () {
        expect(viewModel.tasks, isEmpty);
        expect(viewModel.isLoading, isFalse);
      },
    );

    test(
      'Deve atualizar a lista de tarefas com sucesso ao rodar fetchTasks',
      () async {
        // ARRANGE (Configura o Mock para devolver uma lista de tarefa fake)
        when(
          () => mockRepository.getAllTasks(),
        ).thenAnswer((_) async => [dummyTask]);

        // ACT (Chama o método do ViewModel para teste)
        await viewModel.fetchTasks();

        // ASSERT (Verifica se o estado do ViewModel mudou como esperado)
        expect(viewModel.tasks.length, 1);
        expect(viewModel.tasks.first.title, 'Estudar Testes no Flutter');
        expect(viewModel.isLoading, isFalse);

        // Verifica se o ViewModel realmente chamou o repositório uma vez
        verify(() => mockRepository.getAllTasks()).called(1);
      },
    );

    test(
      'Deve setar isLoading como false mesmo se o repositório falhar',
      () async {
        // ARRANGE (Força o Mock a lançar uma exceção de erro)
        when(
          () => mockRepository.getAllTasks(),
        ).thenThrow(Exception('Erro de conexão'));

        // ACT
        await viewModel.fetchTasks();

        // ASSERT
        expect(viewModel.tasks, isEmpty);
        expect(
          viewModel.isLoading,
          isFalse,
        ); // Garante que o 'finally' funcionou!
      },
    );

    test('move tarefa para a lixeira e permite restaurar', () async {
      var fetchCount = 0;
      when(() => mockRepository.getAllTasks()).thenAnswer((_) async {
        fetchCount++;
        if (fetchCount == 1) return [dummyTask];
        if (fetchCount == 2) {
          return [dummyTask.copyWith(deletedAt: DateTime.now())];
        }
        return [dummyTask];
      });
      when(() => mockRepository.updateTask(any())).thenAnswer((_) async {});

      await viewModel.fetchTasks();
      await viewModel.removeTask(dummyTask.id);
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.trashedTasks, hasLength(1));

      await viewModel.restoreTask(dummyTask.id);
      expect(viewModel.tasks, hasLength(1));
      expect(viewModel.trashedTasks, isEmpty);

      final updates = verify(
        () => mockRepository.updateTask(captureAny()),
      ).captured.cast<Task>();
      expect(updates.first.deletedAt, isNotNull);
      expect(updates.last.deletedAt, isNull);
    });

    test('exclui definitivamente tarefas na lixeira há 15 dias', () async {
      final expiredTask = dummyTask.copyWith(
        id: 'expired',
        deletedAt: DateTime.now().subtract(const Duration(days: 15)),
      );
      when(
        () => mockRepository.getAllTasks(),
      ).thenAnswer((_) async => [dummyTask, expiredTask]);
      when(
        () => mockRepository.deleteTask(expiredTask.id),
      ).thenAnswer((_) async {});

      await viewModel.fetchTasks();

      expect(viewModel.tasks, [dummyTask]);
      expect(viewModel.trashedTasks, isEmpty);
      verify(() => mockRepository.deleteTask(expiredTask.id)).called(1);
    });
  });
}
