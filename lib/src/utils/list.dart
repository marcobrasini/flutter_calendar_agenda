extension ListType<T> on List<T> {
  List<T> roll(int shift) {
    if (isEmpty) return this;
    shift = ((shift % length) + length) % length;
    return [
      ...sublist(length - shift),
      ...sublist(0, length - shift)
    ];
  }
}