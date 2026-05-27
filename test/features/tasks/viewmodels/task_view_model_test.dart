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

  // O setUp roda antes de cada teste, garantindo um ambiente limpo
  setUp(() {
    mockRepository = MockTaskRepository();
    viewModel = TaskViewModel(mockRepository);
  });

  group('TaskViewModel - Testes Unitários', () {
    
    // Tarefa fake
    final dummyTask = Task(
      id: '1',
      title: 'Estudar Testes no Flutter',
      description: 'Sprint 3 do app Focus',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('Deve inicializar com a lista de tarefas vazia e isLoading como false', () {
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.isLoading, isFalse);
    });

    test('Deve atualizar a lista de tarefas com sucesso ao rodar fetchTasks', () async {
      // ARRANGE (Configura o Mock para devolver uma lista de tarefa fake)
      when(() => mockRepository.getAllTasks()).thenAnswer((_) async => [dummyTask]);

      // ACT (Chama o método do ViewModel para teste)
      await viewModel.fetchTasks();

      // ASSERT (Verifica se o estado do ViewModel mudou como esperado)
      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.title, 'Estudar Testes no Flutter');
      expect(viewModel.isLoading, isFalse);
      
      // Verifica se o ViewModel realmente chamou o repositório uma vez
      verify(() => mockRepository.getAllTasks()).called(1);
    });

    test('Deve setar isLoading como false mesmo se o repositório falhar', () async {
      // ARRANGE (Força o Mock a lançar uma exceção de erro)
      when(() => mockRepository.getAllTasks()).thenThrow(Exception('Erro de conexão'));

      // ACT
      await viewModel.fetchTasks();

      // ASSERT
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.isLoading, isFalse); // Garante que o 'finally' funcionou!
    });
  });
}