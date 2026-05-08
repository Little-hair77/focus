import 'dart:convert';

// Enum para prioridade conforme o modelo
enum TaskPriority {  low, medium, high}
// Enum para Status conforme seu modelo
enum TaskStatus { pending, inProgress, done}

class Task{
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? categoryId;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.categoryId,
    this.photoPath,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(), // SQLite não tem tipo Date 
      'priority': priority.index, // Salva como 0, 1 ou 2 
      'status': status.index,     // Salva como 0, 1 ou 2 
      'category_id': categoryId,
      'photo_path': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Converte o que vem do Banco de Dados para o Objeto Dart
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      priority: TaskPriority.values[map['priority'] ?? 1],
      status: TaskStatus.values[map['status'] ?? 0],
      categoryId: map['category_id'],
      photoPath: map['photo_path'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}