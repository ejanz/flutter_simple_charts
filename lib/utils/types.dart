import 'package:flutter/animation.dart';

class DataItem {
  dynamic id;

  String label;

  double value;

  Color? color;

  bool selected;

  DataItem({
    required this.id,
    required this.label,
    required this.value,
    this.color,
    this.selected = false,
  });
}
