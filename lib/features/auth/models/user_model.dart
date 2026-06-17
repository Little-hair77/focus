/// Representa o usuário autenticado dentro da aplicação.
class User {
  /// Identificador único do usuário.
  final String id;

  /// Nome exibido nas telas do app.
  final String name;

  /// E-mail usado para login.
  final String email;

  /// URL remota da foto de perfil, quando disponível.
  final String? photoUrl;

  /// Data em que a conta foi criada.
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  /// Converte o usuário para um mapa persistível.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Cria um usuário a partir dos dados persistidos.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photo_url'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
