import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/utils/enums.dart';
import 'package:flutter_simple_charts/utils/lists.dart';
import 'package:flutter_simple_charts/utils/types.dart';
import 'dart:math' as math;

import 'package:touchable/touchable.dart';

/// A donut chart widget that visualises categorical data as arc sectors.
///
/// Supply a [dataset] of [DataItem] objects and the chart renders each item
/// as a sector whose sweep angle is proportional to its value.
///
/// Example:
/// ```dart
/// DonutChart(
///   title: 'Expenses',
///   dataset: [
///     DataItem(id: 0, label: 'Rent', value: 1200),
///     DataItem(id: 1, label: 'Food', value: 450),
///   ],
/// )
/// ```
class DonutChart extends StatelessWidget {
  /// Creates a [DonutChart].
  const DonutChart({
    super.key,
    required this.dataset,
    this.datasetOrdering,
    this.title = '',
    this.height,
    this.width,
    this.maxWidth = 600.0,
    this.customColors = colors,
    this.backGroundColor,
    this.showTitle = true,
    this.showCenterText = true,
    this.showLabels = true,
    this.showLegend = true,
    this.showLines = true,
    this.onSectorTap = _defaultOnTap,
  });

  static void _defaultOnTap(DataItem sectorValue) {}

  /// The data items to display as donut sectors.
  final List<DataItem> dataset;

  /// Optional ordering applied to [dataset] before rendering.
  ///
  /// When `null`, the original order is preserved.
  final DatasetOrdering? datasetOrdering;

  /// Optional title displayed at the top of the chart.
  final String title;

  /// Fixed height for the chart widget.
  ///
  /// When `null`, the height is calculated automatically based on the screen
  /// width and whether the legend is shown.
  final double? height;

  /// Fixed width for the chart widget.
  ///
  /// When `null`, the width follows the screen width up to [maxWidth].
  final double? width;

  /// Maximum width the chart may occupy. Defaults to `600.0`.
  final double maxWidth;

  /// Color palette used when a [DataItem] does not specify its own color.
  final List<Color> customColors;

  /// Background color of the chart container.
  ///
  /// Defaults to `Theme.of(context).colorScheme.surfaceContainerLow` when
  /// `null`.
  final Color? backGroundColor;

  /// Whether to render the chart title. Defaults to `true`.
  final bool showTitle;

  /// Whether to render total text in the chart center. Defaults to `true`.
  final bool showCenterText;

  /// Whether to render labels near each sector. Defaults to `true`.
  final bool showLabels;

  /// Whether to render the legend below the chart. Defaults to `true`.
  final bool showLegend;

  /// Whether to render separator lines from center to sectors. Defaults to
  /// `true`.
  final bool showLines;

  /// Callback invoked when the user taps a sector.
  ///
  /// Receives the [DataItem] that corresponds to the tapped sector.
  final Function(DataItem) onSectorTap;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    double chartHeight = !showLegend
        ? screenSize.width > maxWidth
              ? maxWidth
              : screenSize.width + 20
        : screenSize.width > maxWidth
        ? maxWidth + (dataset.length * 18) + 60
        : screenSize.width + (dataset.length * 18) + 60;

    if (height != null) {
      chartHeight = height!;
    }

    double chartWidth = screenSize.width > maxWidth
        ? maxWidth
        : screenSize.width;

    if (width != null) {
      chartWidth = width!;
    }

    List<DataItem> datasetOrdered = dataset;

    if (datasetOrdering == DatasetOrdering.crescent) {
      datasetOrdered = [...dataset]..sort((a, b) => a.value.compareTo(b.value));
    } else if (datasetOrdering == DatasetOrdering.decrescent) {
      datasetOrdered = [...dataset]..sort((a, b) => b.value.compareTo(a.value));
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Container(
            color:
                backGroundColor ??
                Theme.of(context).colorScheme.surfaceContainerLow,
            child: SizedBox(
              height: chartHeight,
              width: chartWidth,
              child: CanvasTouchDetector(
                gesturesToOverride: [GestureType.onTapDown],
                builder: (context) => CustomPaint(
                  painter: DonutChartPainter(
                    datasetOrdered,
                    context,
                    title: title,
                    customColors: customColors,
                    backGroundColor: backGroundColor,
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

/// Paints the donut chart sectors, labels, legend, and optional center text.
class DonutChartPainter extends CustomPainter {
  /// Dataset used to render the chart.
  final List<DataItem> dataset;

  /// Build context used for theming and tap detection.
  final BuildContext context;

  /// Title displayed at the top of the chart.
  final String title;

  /// Fallback color palette for sectors.
  final List<Color> customColors;

  /// Optional background color for line separators.
  final Color? backGroundColor;

  /// Whether to show the title.
  final bool showTitle;

  /// Whether to show center text.
  final bool showCenterText;

  /// Whether to show sector labels.
  final bool showLabels;

  /// Whether to show the legend.
  final bool showLegend;

  /// Whether to draw separator lines.
  final bool showLines;

  /// Tap callback triggered when a sector is tapped.
  final Function onTap;

  /// Creates a [DonutChartPainter].
  DonutChartPainter(
    this.dataset,
    this.context, {
    this.title = '',
    required this.customColors,
    this.backGroundColor,
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
      ..color =
          backGroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow
      ..style = PaintingStyle.fill;

    double total = 0.0;
    Offset legendPosition = Offset(30, (diameter + 100.0));
    for (var di in dataset) {
      total += di.value;
    }

    if (showTitle) {
      drawTitle(canvas, size);
    }

    for (DataItem di in dataset) {
      final sweepAngle = di.value / total * fullAngle * math.pi / 180.0;

      final dx = diameter * 0.55 * math.cos(startAngle);
      final dy = diameter * 0.55 * math.sin(startAngle);
      final p = c + Offset(dx, dy);

      drawSector(
        touchyCanvas,
        di,
        di.color ?? customColors[dataset.indexOf(di)],
        rect,
        startAngle,
        sweepAngle,
      );

      if (showLines) {
        drawLines(canvas, c, p, linePaint);
      }

      startAngle += sweepAngle;
    }

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
          di.color ?? customColors[dataset.indexOf(di)],
        );
        legendPosition += const Offset(0, 18);
      }
      startAngle += sweepAngle;
    }

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

  /// Draws a sector arc and registers tap handling.
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

  /// Draws the chart title.
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

  /// Draws a separator line between sectors.
  void drawLines(Canvas canvas, Offset c, Offset p, Paint linePaint) {
    canvas.drawLine(c, p, linePaint);
  }

  /// Draws a label near the middle of a sector.
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

  /// Draws a legend row for a data item.
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

  /// Draws [text] centered at [position] and optionally paints a background.
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

  /// Measures a multi-line string into a [TextPainter].
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
  /// Returns whether this painter should repaint.
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
