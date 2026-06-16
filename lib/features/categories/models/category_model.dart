import 'package:flutter/material.dart';
import 'package:focus/core/theme/category_palette.dart';

/// Representa uma categoria usada para agrupar tarefas.
class Category {
  /// Identificador único da categoria.
  final String id;

  /// Nome exibido para o usuário.
  final String name;

  /// Cor hexadecimal associada à categoria.
  final String color;

  /// Ícone opcional reservado para evolução visual.
  final String? icon;

  /// Data em que a categoria foi criada.
  final DateTime createdAt;

  /// Data de envio para lixeira, quando aplicável.
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
    this.deletedAt,
  });

  /// Cria uma cópia alterando apenas os campos informados.
  Category copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool restore = false,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: restore ? null : deletedAt ?? this.deletedAt,
    );
  }

  /// Cor pronta para uso na interface.
  Color get displayColor {
    return CategoryPalette.parse(color);
  }

  /// Converte a categoria para um mapa persistível.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Cria uma categoria a partir dos dados persistidos.
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
      createdAt: DateTime.parse(map['created_at']),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'])
          : null,
    );
  }
}
