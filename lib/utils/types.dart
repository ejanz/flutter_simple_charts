/// The data type to donut and bar chart
class DataItem {
  /// The [id] of each dataset item
  dynamic id;

  /// The [label] of each dataset item
  String label;

  /// The [value] of each dataset tiem
  double value;

  /// Not used yet, for future updates
  bool selected;

  /// Dataset type
  DataItem({
    required this.id,
    required this.label,
    required this.value,
    this.selected = false,
  });
}
