class DataItem {
  dynamic id;
  String label;
  double value;
  bool selected;

  DataItem({
    required this.id,
    required this.label,
    required this.value,
    this.selected = false,
  });
}
