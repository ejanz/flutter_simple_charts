/// The data type to donut and bar chart
class DataItem {
  /// The [id] of each dataset item
  dynamic id;

  /// The [label] of each dataset item
  String label;

  /// The [value] of each dataset item
  double value;

  /// Not used yet, for future updates
  bool selected;

  /// An optional custom [Color] for this item.
  ///
  /// When provided, this color is used for the sector or bar representing
  /// this item instead of the chart's [customColors] palette.
  Color? color;

  /// Dataset type
  DataItem({
    required this.id,
    required this.label,
    required this.value,
    this.selected = false,
    this.color,
  });
}
