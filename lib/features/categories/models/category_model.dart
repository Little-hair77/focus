import 'package:flutter/material.dart';
import 'package:focus/core/theme/category_palette.dart';

class Category {
  final String id;
  final String name;
  final String color;
  final String? icon;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
    this.deletedAt,
  });

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

  Color get displayColor {
    return CategoryPalette.parse(color);
  }

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
