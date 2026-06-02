import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/data/repositories/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  @override
  Future<void> insertTask(Task task) async {
    // Insere no Firestore usando o toMap()
    await _tasksCollection.doc(task.id).set(task.toMap());
  }

  @override
  Future<List<Task>> getAllTasks() async {
    // Busca todos os documentos dentro da coleção 'tasks'
    final snapshot = await _tasksCollection.get();

    // Converte os documentos retornados para instâncias da classe Task
    return snapshot.docs.map((doc) {
      // Passa o doc.data() para o fromMap da sua classe Task
      return Task.fromMap(doc.data());
    }).toList();
  }

  @override
  Future<void> updateTask(Task task) async {
    // Atualiza o documento no Firebase usando o ID da tarefa 
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  @override
  Future<void> deleteTask(String id) async {
    // Deleta o documento pelo ID
    await _tasksCollection.doc(id).delete();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final doc = await _tasksCollection.doc(id).get();

    if (doc.exists && doc.data() != null) {
      return Task.fromMap(doc.data()!);
    }
    return null;
  }
}
