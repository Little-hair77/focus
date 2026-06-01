enum TrashItemType { task, category }

class TrashDragData {
  final String id;
  final TrashItemType type;

  const TrashDragData({required this.id, required this.type});
}
