import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/utils/enums.dart';
import 'package:flutter_simple_charts/utils/types.dart';

import 'package:touchable/touchable.dart';

/// A bar chart widget that displays data segments as colored bars.
///
/// The [BarChart] widget visualizes a dataset as a bar chart with optional
/// features including title, labels, legend, and interactive tap handlers.
///
/// Features:
/// - Customizable title and data labels
/// - Optional legend display
/// - Optional connecting lines from center to labels
/// - Tap handling for individual sectors
/// - Optional dataset sorting (ascending/descending)
///
/// Example:
/// ```dart
/// BarChart(
///   title: 'Sales Distribution',
///   dataset: dataItems,
///   showLabels: true,
///   showLegend: true,
///   onBarTap: (item) => print('${item.label}: ${item.value}'),
/// )
/// ```
class BarChart extends StatelessWidget {
  /// Creates a [BarChart] widget.
  ///
  /// The [dataset] parameter is required and must contain at least one [DataItem].
  /// All other parameters have sensible defaults.
  const BarChart({
    super.key,
    required this.dataset,
    this.title = '',
    this.showTitle = true,
    this.showLabels = true,
    this.showLegend = false,
    this.showLines = true,
    this.onBarTap = _defaultOnTap,
    this.datasetOrdering,
  });

  /// Default no-op callback for bar tap events.
  static void _defaultOnTap(DataItem barValue) {}

  /// The data items to display in the chart.
  /// Each [DataItem] represents a bar in the bar chart.
  final List<DataItem> dataset;

  /// The title text displayed at the top of the chart.
  /// Defaults to an empty string.
  final String title;

  /// Whether to display the chart title.
  /// Defaults to true.
  final bool showTitle;

  /// Whether to display labels on each bar of the chart.
  /// Defaults to true.
  final bool showLabels;

  /// Whether to display a legend below the chart.
  /// The legend shows each item's label, value, and percentage.
  /// Defaults to true.
  final bool showLegend;

  /// Whether to display connecting lines from center to labels.
  /// Defaults to true.
  final bool showLines;

  /// Callback function triggered when a sector is tapped.
  /// Called with the [DataItem] corresponding to the tapped sector.
  /// Defaults to a no-op function.
  final Function(DataItem) onBarTap;

  /// Optional sorting order for the dataset.
  /// Can be [DatasetOrdering.crescent], [DatasetOrdering.decrescent], or null.
  /// When null, items display in their original order.
  final DatasetOrdering? datasetOrdering;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    List<DataItem> datasetOrdered = dataset;

    // Sort dataset if ordering is specified
    if (datasetOrdering == DatasetOrdering.crescent) {
      datasetOrdered = [...dataset]..sort((a, b) => a.value.compareTo(b.value));
    } else if (datasetOrdering == DatasetOrdering.decrescent) {
      datasetOrdered = [...dataset]..sort((a, b) => b.value.compareTo(a.value));
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          SizedBox(
            height: !showLegend
                ? screenSize.width > 600
                      ? 600
                      : screenSize.width
                : screenSize.width > 600
                ? 600 + (datasetOrdered.length * 18) + 50
                : screenSize.width + (datasetOrdered.length * 18) + 50,
            width: screenSize.width > 600 ? 600 : screenSize.width,
            child: Card(
              elevation: 15,
              child: CanvasTouchDetector(
                gesturesToOverride: [GestureType.onTapDown],
                builder: (context) => CustomPaint(
                  painter: BarChartPainter(
                    datasetOrdered,
                    context,
                    title: title,
                    showTitle: showTitle,
                    showLabels: showLabels,
                    showLegend: showLegend,
                    showLines: showLines,
                    onTap: (DataItem value) => onBarTap(value),
                  ),
                  willChange: true,
                  isComplex: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for rendering the bar chart on a canvas.
///
/// This painter handles all drawing operations including:
/// - Bars with colors
/// - Title text
/// - Sector labels with background
/// - Legend entries
/// - Connecting lines
/// - Touch detection for interactive elements
class BarChartPainter extends CustomPainter {
  /// The data items to render.
  final List<DataItem> dataset;

  /// The build context used for theme and text styling.
  final BuildContext context;

  /// The chart title.
  final String title;

  /// Whether to show the title.
  final bool showTitle;

  /// Whether to show sector labels.
  final bool showLabels;

  /// Whether to show the legend.
  final bool showLegend;

  /// Whether to show connecting lines.
  final bool showLines;

  /// Callback for sector tap events.
  final Function onTap;

  /// Creates a [BarChartPainter].
  BarChartPainter(
    this.dataset,
    this.context, {
    this.title = '',
    this.showTitle = true,
    this.showLabels = true,
    this.showLegend = true,
    this.showLines = true,
    required this.onTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    TouchyCanvas touchyCanvas = TouchyCanvas(context, canvas);

    final greaterDataset = dataset.reduce(
      (dMax, d) => d.value > dMax.value ? d : dMax,
    );

    final double barWidth = size.width / (dataset.length * 1.25);
    final double maxHeight = showLegend
        ? size.height - 30 - (dataset.length * 18)
        : size.height - 30;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    /// Draw title
    if (showTitle) {
      drawTitle(canvas, size);
    }

    /// Draw scale X lines
    drawLines(canvas, size, maxHeight);

    /// Draw each bar os chart
    drawBars(
      touchyCanvas,
      paint,
      size,
      barWidth,
      maxHeight,
      dataset,
      greaterDataset,
    );

    ///Draw labels
    if (showLabels) {
      drawLabel(canvas, size, barWidth, maxHeight, dataset, greaterDataset);
    }

    ///Draw legend
    if (showLegend) {
      drawLegend(canvas, size, dataset);
    }
  }

  void drawLines(Canvas canvas, Size size, double maxHeight) {
    int subDivisions = ((maxHeight - 150) / 50).toInt();

    Paint mainPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;

    Paint secPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.7;

    Offset mP1 = Offset(10, maxHeight + 2);
    Offset mP2 = Offset(size.width - 10, maxHeight + 2);
    Offset mP3 = Offset(15, maxHeight + 6);
    Offset mP4 = Offset(15, 100);

    canvas.drawLine(mP1, mP2, mainPaint);
    canvas.drawLine(mP3, mP4, mainPaint);

    for (var i = 0; i <= subDivisions; i++) {
      Offset sP1 = Offset(10, maxHeight - (i + 1) * 50);
      Offset sP2 = Offset(size.width - 10, maxHeight - (i + 1) * 50);

      canvas.drawLine(sP1, sP2, secPaint);
    }
  }

  /// Draws a single bar of the chart.
  ///
  /// Parameters:
  /// - [touchyCanvas] : Canvas with touch detection capabilities
  /// - [paint] : The paint to draw item for this bar
  /// - [size] : The size to draw the chart
  /// - [barWidth] : The width of each bar
  /// - [maxHeight] : The max height to calculate the X scale
  /// - [dataset] : The data itens for this chart
  /// - [greaterDataset] : The grater dataset to calculate the X scale
  void drawBars(
    TouchyCanvas touchyCanvas,
    Paint paint,
    Size size,
    double barWidth,
    double maxHeight,
    List<DataItem> dataset,
    DataItem greaterDataset,
  ) {
    for (int i = 0; i < dataset.length; i++) {
      double heightFactor = greaterDataset.value / (maxHeight - 150);
      double barHeight = maxHeight - dataset[i].value / heightFactor;
      double x = (i * barWidth * 1.1) + 20;
      paint.color = ColorSeed.values[i].color;
      touchyCanvas.drawRect(
        Rect.fromPoints(Offset(x, barHeight), Offset(x + barWidth, maxHeight)),
        paint,
        onTapDown: (detail) => onTap(dataset[i]),
      );
    }
  }

  /// Draws a label for a bar with a rounded background box.
  ///
  /// Parameters:
  /// - [canvas] : The canvas to draw on
  /// - [size] : The size to draw the label
  /// - [barWidth] : The width of each bar to calculate label position
  /// - [maxHeight] : The max height to calculate lbel position
  /// - [dataset] : The data itens for this chart
  /// - [greaterDataset] : The grater dataset to calculate label position
  void drawLabel(
    Canvas canvas,
    Size size,
    double barWidth,
    double maxHeight,
    List<DataItem> dataset,
    DataItem greaterDataset,
  ) {
    for (int i = 0; i < dataset.length; i++) {
      double heightFactor = greaterDataset.value / (maxHeight - 150);
      double barHeight = maxHeight - 10 - dataset[i].value / heightFactor;
      double x = (i * barWidth * 1.1) + (barWidth / 2) + 15;

      TextSpan label = TextSpan(
        text: dataset[i].label,
        style: TextStyle(fontSize: 14, color: ColorSeed.values[i].color),
      );
      final labelPainter = TextPainter(
        text: label,
        textDirection: TextDirection.ltr,
      );

      labelPainter.layout(minWidth: 0, maxWidth: size.width);
      Offset center = Offset(x, barHeight);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 3);
      canvas.translate(-center.dx, -center.dy);
      labelPainter.paint(canvas, Offset(center.dx, center.dy));
      canvas.restore();
    }
  }

  /// Draws the chart title at the top.
  ///
  /// Parameters:
  /// - [canvas] : The canvas to draw on
  /// - [size] : The size of the canvas
  void drawTitle(Canvas canvas, Size size) {
    TextSpan textSpan = TextSpan(
      text: title,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontSize: 22.0,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    textPainter.paint(canvas, const Offset(10, 10));
  }

  /// Draws a legend entry showing the item name, value, and percentage.
  ///
  /// Parameters:
  /// - [canvas] : The canvas to draw on
  /// - [size] : The size of the canvas
  /// - [dataset] : The data itens for this legend
  void drawLegend(Canvas canvas, Size size, List<DataItem> dataset) {
    Offset legendPosition = Offset(30, (size.height - dataset.length * 18));

    double total = 0.0;

    for (var d in dataset) {
      total += d.value;
    }

    for (int i = 0; i < dataset.length; i++) {
      final legendPaint = Paint()
        ..strokeWidth = 1.0
        ..style = PaintingStyle.fill
        ..color = ColorSeed.values[i].color;

      TextSpan textSpanPercent = TextSpan(
        text: '${((dataset[i].value / total) * 100).toStringAsFixed(2)} %',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 14.0,
        ),
      );

      TextSpan textSpan = TextSpan(
        text: '${dataset[i].label} - ${dataset[i].value.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 14.0,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      final textPainterPercent = TextPainter(
        text: textSpanPercent,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainterPercent.layout(minWidth: 0, maxWidth: size.width);

      textPainterPercent.paint(canvas, legendPosition + const Offset(-15, -10));

      canvas.drawRect(
        Rect.fromLTWH(legendPosition.dx + 40, legendPosition.dy - 8, 20, 15),

        Paint()..color = legendPaint.color,
      );
      textPainter.paint(canvas, legendPosition + const Offset(65, -10));

      legendPosition += const Offset(0, 18);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
