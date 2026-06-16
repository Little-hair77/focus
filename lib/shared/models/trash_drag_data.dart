/// Tipos de item que podem ser arrastados para a lixeira.
enum TrashItemType { task, category }

/// Dados transportados durante o gesto de arrastar para a lixeira.
class TrashDragData {
  /// Identificador do item arrastado.
  final String id;

  /// Tipo do item arrastado.
  final TrashItemType type;

  const TrashDragData({required this.id, required this.type});
}
