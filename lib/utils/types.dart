import 'package:flutter/animation.dart';

/// Represents a single data point used in charts.
///
/// Each [DataItem] holds an identifier, a display label, a numeric value,
/// an optional custom color, and a selection state.
class DataItem {
  /// A unique identifier for this data item.
  dynamic id;

  /// The display label shown alongside the data point (e.g., in legends and tooltips).
  String label;

  /// The numeric value of this data point.
  double value;

  /// An optional color used to render this data point.
  ///
  /// When `null`, the chart falls back to its default color palette.
  Color? color;

  /// Whether this data point is currently selected.
  ///
  /// A selected bar or sector is rendered with a larger stroke to highlight it.
  bool selected;

  /// Creates a [DataItem].
  ///
  /// The [id], [label], and [value] parameters are required.
  /// [color] is optional; if omitted the chart uses its default color palette.
  /// [selected] defaults to `false`.
  DataItem({
    required this.id,
    required this.label,
    required this.value,
    this.color,
    this.selected = false,
  });
}
