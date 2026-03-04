import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/utils/enums.dart';
import 'package:flutter_simple_charts/utils/types.dart';
import 'dart:math' as math;

import 'package:touchable/touchable.dart';

/// A donut/ring chart widget that displays data segments as colored arcs.
///
/// The [DonutChart] widget visualizes a dataset as a donut chart with optional
/// features including title, center text, labels, legend, and interactive tap handlers.
///
/// Features:
/// - Customizable title and data labels
/// - Optional legend display
/// - Optional center text showing total value
/// - Optional connecting lines from center to labels
/// - Tap handling for individual sectors
/// - Optional dataset sorting (ascending/descending)
///
/// Example:
/// ```dart
/// DonutChart(
///   title: 'Sales Distribution',
///   dataset: dataItems,
///   showLabels: true,
///   showLegend: true,
///   onSectorTap: (item) => print('${item.label}: ${item.value}'),
/// )
/// ```
class DonutChart extends StatelessWidget {
  /// Creates a [DonutChart] widget.
  ///
  /// The [dataset] parameter is required and must contain at least one [DataItem].
  /// All other parameters have sensible defaults.
  const DonutChart({
    super.key,
    required this.dataset,
    this.title = '',
    this.showTitle = true,
    this.showCenterText = true,
    this.showLabels = true,
    this.showLegend = true,
    this.showLines = true,
    this.onSectorTap = _defaultOnTap,
    this.datasetOrdering,
  });

  /// Default no-op callback for sector tap events.
  static void _defaultOnTap(DataItem sectorValue) {}

  /// The data items to display in the chart.
  /// Each [DataItem] represents a sector in the donut chart.
  final List<DataItem> dataset;

  /// The title text displayed at the top of the chart.
  /// Defaults to an empty string.
  final String title;

  /// Whether to display the chart title.
  /// Defaults to true.
  final bool showTitle;

  /// Whether to display text in the center of the donut.
  /// When true, displays the total value of all items.
  /// Defaults to true.
  final bool showCenterText;

  /// Whether to display labels on each sector of the donut.
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
  final Function(DataItem) onSectorTap;

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
                      : screenSize.width + 20
                : screenSize.width > 600
                ? 600 + (datasetOrdered.length * 18) + 60
                : screenSize.width + (datasetOrdered.length * 18) + 60,
            width: screenSize.width > 600 ? 600 : screenSize.width,
            child: Card(
              elevation: 15.0,

              child: CanvasTouchDetector(
                gesturesToOverride: [GestureType.onTapDown],
                builder: (context) => CustomPaint(
                  painter: DonutChartPainter(
                    datasetOrdered,
                    context,
                    title: title,
                    showTitle: showTitle,
                    showCenterText: showCenterText,
                    showLabels: showLabels,
                    showLegend: showLegend,
                    showLines: showLines,
                    onTap: (DataItem value) => onSectorTap(value),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for rendering the donut chart on a canvas.
///
/// This painter handles all drawing operations including:
/// - Donut sectors with colors
/// - Title text
/// - Sector labels with background
/// - Legend entries
/// - Center text
/// - Connecting lines
/// - Touch detection for interactive elements
class DonutChartPainter extends CustomPainter {
  /// The data items to render.
  final List<DataItem> dataset;

  /// The build context used for theme and text styling.
  final BuildContext context;

  /// The chart title.
  final String title;

  /// Whether to show the title.
  final bool showTitle;

  /// Whether to show center text.
  final bool showCenterText;

  /// Whether to show sector labels.
  final bool showLabels;

  /// Whether to show the legend.
  final bool showLegend;

  /// Whether to show connecting lines.
  final bool showLines;

  /// Callback for sector tap events.
  final Function onTap;

  /// Creates a [DonutChartPainter].
  DonutChartPainter(
    this.dataset,
    this.context, {
    this.title = '',
    this.showTitle = true,
    this.showCenterText = true,
    this.showLabels = true,
    this.showLegend = true,
    this.showLines = true,
    required this.onTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    TouchyCanvas touchyCanvas = TouchyCanvas(context, canvas);

    final diameter = size.width * 0.85;
    final c = Offset(size.width / 2.0, diameter / 2.0 + 60.0);
    final rect = Rect.fromCenter(center: c, width: diameter, height: diameter);
    const fullAngle = 360.0;
    double startAngle = 0.0;

    final linePaint = Paint()
      ..strokeWidth = 3.0
      ..color = Theme.of(context).colorScheme.surfaceContainerLow
      ..style = PaintingStyle.fill;

    double total = 0.0;
    Offset legendPosition = Offset(30, (diameter + 100.0));
    for (var di in dataset) {
      total += di.value;
    }

    if (showTitle) {
      drawTitle(canvas, size);
    }

    //draw sectors and lines
    for (DataItem di in dataset) {
      final sweepAngle = di.value / total * fullAngle * math.pi / 180.0;

      final dx = diameter * 0.55 * math.cos(startAngle);
      final dy = diameter * 0.55 * math.sin(startAngle);
      final p = c + Offset(dx, dy);

      drawSector(
        touchyCanvas,
        di,
        ColorSeed.values[dataset.indexOf(di)].color,
        rect,
        startAngle,
        sweepAngle,
      );

      if (showLines) {
        drawLines(canvas, c, p, linePaint);
      }

      startAngle += sweepAngle;
    }

    // draw labels and legend
    for (final (int index, DataItem di) in dataset.indexed) {
      final sweepAngle = di.value / total * fullAngle * math.pi / 180.0;

      if (showLabels) {
        drawLabels(
          canvas,
          c,
          diameter,
          startAngle,
          sweepAngle,
          di.label,
          index,
        );
      }

      if (showLegend) {
        drawLegend(
          canvas,
          size,
          legendPosition,
          di,
          total,
          ColorSeed.values[dataset.indexOf(di)].color,
        );
        legendPosition += const Offset(0, 18);
      }
      startAngle += sweepAngle;
    }

    // draw center text
    if (showCenterText) {
      drawTextCentered(
        canvas,
        c,
        'Total\n${total.toStringAsFixed(2)}',
        Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 28.0,
        ),
        diameter * 0.6,
        (Size sz) {},
      );
    }
  }

  /// Draws a single donut sector as an arc.
  ///
  /// Parameters:
  /// - [touchyCanvas] : Canvas with touch detection capabilities
  /// - [di] : The data item for this sector
  /// - [sectorColor] : The color to fill the sector with
  /// - [rect] : The bounding rectangle for the arc
  /// - [startAngle] : Starting angle in radians
  /// - [sweepAngle] : Angle span of the sector in radians
  void drawSector(
    TouchyCanvas touchyCanvas,
    DataItem di,
    Color sectorColor,
    Rect rect,
    double startAngle,
    double sweepAngle,
  ) {
    final sectorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = di.selected ? 60.0 : 20.0
      ..color = sectorColor;

    touchyCanvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      sectorPaint,
      onTapDown: (datails) => onTap(di),
    );
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

  /// Draws a connecting line from the center to a label position.
  ///
  /// Parameters:
  /// - [canvas] : The canvas to draw on
  /// - [c] : The center point of the donut
  /// - [p] : The end point of the line (label position)
  /// - [linePaint] : The paint style for the line
  void drawLines(Canvas canvas, Offset c, Offset p, Paint linePaint) {
    canvas.drawLine(c, p, linePaint);
  }

  /// Draws a label for a sector with a rounded background box.
  ///
  /// Parameters:
  /// - [canvas] : The canvas to draw on
  /// - [c] : The center of the donut
  /// - [diameter] : The diameter of the donut
  /// - [startAngle] : Starting angle of the sector in radians
  /// - [sweepAngle] : Angle span of the sector in radians
  /// - [label] : The text label to display
  /// - [index] : The index of this data item
  void drawLabels(
    Canvas canvas,
    Offset c,
    double diameter,
    double startAngle,
    double sweepAngle,
    String label,
    int index,
  ) {
    final r = diameter * 0.5;
    final dx = r * math.cos(startAngle + sweepAngle / 2.0);
    final dy = r * math.sin(startAngle + sweepAngle / 2.0);
    final position = c + Offset(dx, dy);

    final borderLabelPaint = Paint()
      ..strokeWidth = 1.0
      ..color = Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(50)
      ..style = PaintingStyle.fill;

    final labelPaint = Paint()
      ..strokeWidth = 1.0
      ..color = Theme.of(context).colorScheme.secondaryContainer.withAlpha(70)
      ..style = PaintingStyle.fill;

    /// Draw label´s text
    drawTextCentered(
      canvas,
      position,
      label,
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontSize: 10.0,
        fontWeight: FontWeight.w900,
        textBaseline: TextBaseline.ideographic,
      ),
      75.0,
      (Size sz) {
        final borderRect = Rect.fromCenter(
          center: position,
          width: sz.width + 6,
          height: sz.height + 6,
        );
        final rect = Rect.fromCenter(
          center: position,
          width: sz.width + 5,
          height: sz.height + 5,
        );
        final borderRrect = RRect.fromRectAndRadius(
          borderRect,
          const Radius.circular(5),
        );
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
        canvas.drawRRect(borderRrect, borderLabelPaint);
        canvas.drawRRect(rrect, labelPaint);
      },
    );
  }

  /// Draws a legend entry showing the item name, value, and percentage.
  ///
  /// Parameters:
  /// - [canvas] : The canvas to draw on
  /// - [size] : The size of the canvas
  /// - [legendPosition] : The position to draw this legend entry
  /// - [di] : The data item to display
  /// - [total] : The total sum of all values
  /// - [sectorColor] : The color associated with this data item
  void drawLegend(
    Canvas canvas,
    Size size,
    Offset legendPosition,
    DataItem di,
    double total,
    Color sectorColor,
  ) {
    final legendPaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..color = sectorColor;

    TextSpan textSpanPercent = TextSpan(
      text: '${((di.value / total) * 100).toStringAsFixed(2)} %',
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontSize: 14.0,
      ),
    );

    TextSpan textSpan = TextSpan(
      text: '${di.label} - ${di.value.toStringAsFixed(2)}',
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
  }

  /// Draws text centered at a specific position with optional background.
  ///
  /// Parameters:
  /// - [canvas] : The canvas to draw on
  /// - [position] : The center position for the text
  /// - [text] : The text content to display
  /// - [style] : The text style to apply
  /// - [maxWidth] : Maximum width constraint for the text
  /// - [bgCb] : Callback function that receives the text size,
  ///   typically used to draw a background behind the text
  void drawTextCentered(
    Canvas canvas,
    Offset position,
    String text,
    TextStyle style,
    double maxWidth,
    Function(Size sz) bgCb,
  ) {
    final tp = measureText(text, style, maxWidth, TextAlign.center);
    final pos = position + Offset(-tp.width / 2.0, -tp.height / 2.0);
    bgCb(tp.size);
    tp.paint(canvas, pos);
  }

  /// Measures text dimensions without painting it.
  ///
  TextPainter measureText(
    String s,
    TextStyle style,
    double maxWidth,
    TextAlign align,
  ) {
    final span = TextSpan(text: s, style: style);
    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: 0, maxWidth: maxWidth);
    return tp;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
