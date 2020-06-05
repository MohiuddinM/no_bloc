enum ListOpType { add, remove, clear, error }

class ListOp<T> {
  final T item;
  final ListOpType type;

  const ListOp(this.item, this.type);

  @override
  int get hashCode => item.hashCode + type.hashCode;

  @override
  bool operator ==(other) {
    return other is ListOp<T> && other.item == item && other.type == type;
  }

  @override
  String toString() => '($item, $type)';
}
