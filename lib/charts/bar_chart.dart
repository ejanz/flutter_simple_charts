import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/utils/enums.dart';
import 'package:flutter_simple_charts/utils/lists.dart';
import 'package:flutter_simple_charts/utils/types.dart';

import 'package:touchable/touchable.dart';

/// A bar chart widget that visualises categorical data as vertical bars.
///
/// Supply a [dataset] of [DataItem] objects and the chart will render each item
/// as a bar whose height is proportional to its value.
///
/// Example:
/// ```dart
/// BarChart(
///   title: 'Fruits',
///   dataset: [
///     DataItem(id: 0, label: 'Apples', value: 50),
///     DataItem(id: 1, label: 'Oranges', value: 30),
///   ],
/// )
/// ```
class BarChart extends StatefulWidget {
  /// Creates a [BarChart].
  const BarChart({
    super.key,
    required this.dataset,
    this.title = '',
    this.showTitle = true,
    this.height,
    this.width,
    this.maxWidth = 600.0,
    this.customColors = colors,
    this.backGroundColor,
    this.showLabels = true,
    this.showLegend = false,
    this.showLines = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 900),
    this.animationCurve = Curves.easeOutCubic,
    this.onBarTap = _defaultOnTap,
    this.datasetOrdering,
  });

  static void _defaultOnTap(DataItem barValue) {}

  /// The data items to display as bars.
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

  /// Whether to render bar labels below each bar. Defaults to `true`.
  final bool showLabels;

  /// Whether to render the legend below the chart. Defaults to `false`.
  final bool showLegend;

  /// Whether to render the horizontal grid lines. Defaults to `true`.
  final bool showLines;

  /// Whether to animate the chart when it is first shown or rebuilt.
  ///
  /// Defaults to `true`.
  final bool animate;

  /// Duration of the entry animation.
  final Duration animationDuration;

  /// Curve used by the entry animation.
  final Curve animationCurve;

  /// Callback invoked when the user taps a bar.
  ///
  /// Receives the [DataItem] that corresponds to the tapped bar.
  final Function(DataItem) onBarTap;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _configureAnimation(restart: true);
  }

  void _configureAnimation({required bool restart}) {
    _controller.duration = widget.animationDuration;
    _animation = CurvedAnimation(parent: _controller, curve: widget.animationCurve);

    if (!widget.animate) {
      _controller.value = 1.0;
      return;
    }

    if (restart) {
      _controller
        ..value = 0.0
        ..forward();
    }
  }

  @override
  void didUpdateWidget(covariant BarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldRestart =
        widget.animate &&
        (oldWidget.animate != widget.animate ||
            oldWidget.animationDuration != widget.animationDuration ||
            oldWidget.animationCurve != widget.animationCurve ||
            oldWidget.datasetOrdering != widget.datasetOrdering ||
            !identical(oldWidget.dataset, widget.dataset) ||
            oldWidget.dataset.length != widget.dataset.length);

    if (!widget.animate) {
      _controller.value = 1.0;
      return;
    }

    if (shouldRestart) {
      _configureAnimation(restart: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    double chartHeight = !widget.showLegend
        ? screenSize.width > widget.maxWidth
              ? widget.maxWidth
              : screenSize.width + 20
        : screenSize.width > widget.maxWidth
        ? widget.maxWidth + (widget.dataset.length * 18) + 60
        : screenSize.width + (widget.dataset.length * 18) + 60;

    if (widget.height != null) {
      chartHeight = widget.height!;
    }

    double chartWidth = screenSize.width > widget.maxWidth
        ? widget.maxWidth
        : screenSize.width;

    if (widget.width != null) {
      chartWidth = widget.width!;
    }

    List<DataItem> datasetOrdered = widget.dataset;

    if (widget.datasetOrdering == DatasetOrdering.crescent) {
      datasetOrdered = [...widget.dataset]
        ..sort((a, b) => a.value.compareTo(b.value));
    } else if (widget.datasetOrdering == DatasetOrdering.decrescent) {
      datasetOrdered = [...widget.dataset]
        ..sort((a, b) => b.value.compareTo(a.value));
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Container(
            color:
                widget.backGroundColor ??
                Theme.of(context).colorScheme.surfaceContainerLow,
            child: SizedBox(
              height: chartHeight,
              width: chartWidth,

              child: CanvasTouchDetector(
                gesturesToOverride: [GestureType.onTapDown],
                builder: (context) => CustomPaint(
                  painter: BarChartPainter(
                    datasetOrdered,
                    context,
                    animation: _animation,
                    title: widget.title,
                    customColors: widget.customColors,
                    backGroundColor: widget.backGroundColor,
                    showTitle: widget.showTitle,
                    showLabels: widget.showLabels,
                    showLegend: widget.showLegend,
                    showLines: widget.showLines,
                    onTap: (DataItem value) => widget.onBarTap(value),
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

/// Paints the bars, labels, title, legend, and grid lines for a [BarChart].
class BarChartPainter extends CustomPainter {
  /// Dataset used to render the chart.
  final List<DataItem> dataset;

  /// Build context used for theming and tap detection.
  final BuildContext context;

  /// Title displayed at the top of the chart.
  final String title;

  /// Fallback color palette for bars.
  final List<Color> customColors;

  /// Optional background color (currently used by the chart container).
  final Color? backGroundColor;

  /// Whether to show the title.
  final bool showTitle;

  /// Whether to show rotated labels for each bar.
  final bool showLabels;

  /// Whether to show the legend below the chart.
  final bool showLegend;

  /// Whether to draw horizontal grid lines.
  final bool showLines;

  /// Tap callback triggered when a bar is tapped.
  final Function onTap;

  /// Animation driving the entry of the bars.
  final Animation<double> animation;

  /// Creates a [BarChartPainter].
  BarChartPainter(
    this.dataset,
    this.context, {
    required this.animation,
    this.title = '',
    required this.customColors,
    this.backGroundColor,
    this.showTitle = true,
    this.showLabels = true,
    this.showLegend = true,
    this.showLines = true,
    required this.onTap,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    TouchyCanvas touchyCanvas = TouchyCanvas(context, canvas);

    final palette = customColors.isEmpty ? colors : customColors;

    if (dataset.isEmpty) {
      if (showTitle) {
        drawTitle(canvas, size);
      }
      return;
    }

    final t = animation.value.clamp(0.0, 1.0);

    final greaterDataset = dataset.reduce(
      (dMax, d) => d.value > dMax.value ? d : dMax,
    );

    final double barWidth = size.width / (dataset.length * 1.25);
    final double maxHeight = showLegend
        ? size.height - 30 - (dataset.length * 18)
        : size.height - 30;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    if (showTitle) {
      drawTitle(canvas, size);
    }

    drawLines(canvas, size, maxHeight);

    drawBars(
      touchyCanvas,
      paint,
      size,
      barWidth,
      maxHeight,
      dataset,
      greaterDataset,
      t,
      palette,
    );

    if (showLabels) {
      drawLabel(
        canvas,
        size,
        barWidth,
        maxHeight,
        dataset,
        greaterDataset,
        t,
        palette,
      );
    }

    if (showLegend) {
      drawLegend(canvas, size, dataset, t, palette);
    }
  }

  /// Draws the main axis line and grid lines.
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

  /// Draws the chart bars and wires up tap handling.
  void drawBars(
    TouchyCanvas touchyCanvas,
    Paint paint,
    Size size,
    double barWidth,
    double maxHeight,
    List<DataItem> dataset,
    DataItem greaterDataset,
    double t,
    List<Color> palette,
  ) {
    final usableHeight = math.max(1.0, maxHeight - 150);
    final heightFactor =
        greaterDataset.value == 0.0 ? 1.0 : (greaterDataset.value / usableHeight);
    for (int i = 0; i < dataset.length; i++) {
      final fullTop =
          greaterDataset.value == 0.0 ? maxHeight : (maxHeight - dataset[i].value / heightFactor);
      final barTop = ui.lerpDouble(maxHeight, fullTop, t) ?? fullTop;
      double x = (i * barWidth * 1.1) + 20;
      paint.color = dataset[i].color ?? palette[i % palette.length];
      touchyCanvas.drawRect(
        Rect.fromPoints(Offset(x, barTop), Offset(x + barWidth, maxHeight)),
        paint,
        onTapDown: (detail) => onTap(dataset[i]),
      );
    }
  }

  /// Draws rotated labels near each bar.
  void drawLabel(
    Canvas canvas,
    Size size,
    double barWidth,
    double maxHeight,
    List<DataItem> dataset,
    DataItem greaterDataset,
    double t,
    List<Color> palette,
  ) {
    final usableHeight = math.max(1.0, maxHeight - 150);
    final heightFactor =
        greaterDataset.value == 0.0 ? 1.0 : (greaterDataset.value / usableHeight);
    final alpha = (((t - 0.65) / 0.35).clamp(0.0, 1.0) * 255).round();
    for (int i = 0; i < dataset.length; i++) {
      final fullTop =
          greaterDataset.value == 0.0
              ? maxHeight
              : (maxHeight - 10 - dataset[i].value / heightFactor);
      final barTop = ui.lerpDouble(maxHeight, fullTop, t) ?? fullTop;
      double x = (i * barWidth * 1.1) + (barWidth / 2) + 15;

      TextSpan label = TextSpan(
        text: dataset[i].label,
        style: TextStyle(
          fontSize: 14,
          color: (dataset[i].color ?? palette[i % palette.length])
              .withAlpha(alpha),
        ),
      );
      final labelPainter = TextPainter(
        text: label,
        textDirection: TextDirection.ltr,
      );

      labelPainter.layout(minWidth: 0, maxWidth: size.width);
      Offset center = Offset(x, barTop);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 3);
      canvas.translate(-center.dx, -center.dy);
      labelPainter.paint(canvas, Offset(center.dx, center.dy));
      canvas.restore();
    }
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

  /// Draws the legend below the chart.
  void drawLegend(
    Canvas canvas,
    Size size,
    List<DataItem> dataset,
    double t,
    List<Color> palette,
  ) {
    final alpha = (((t - 0.7) / 0.3).clamp(0.0, 1.0) * 255).round();
    Offset legendPosition = Offset(30, (size.height - dataset.length * 18));

    double total = 0.0;

    for (var d in dataset) {
      total += d.value;
    }

    for (int i = 0; i < dataset.length; i++) {
      final legendPaint = Paint()
        ..strokeWidth = 1.0
        ..style = PaintingStyle.fill
        ..color =
            (dataset[i].color ?? palette[i % palette.length]).withAlpha(alpha);

      TextSpan textSpanPercent = TextSpan(
        text: '${((dataset[i].value / total) * 100).toStringAsFixed(2)} %',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(alpha),
          fontSize: 14.0,
        ),
      );

      TextSpan textSpan = TextSpan(
        text: '${dataset[i].label} - ${dataset[i].value.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(alpha),
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
  /// Returns whether this painter should repaint.
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // We repaint whenever the animation ticks (via super(repaint: animation)).
    // Still return true to be safe when non-animation inputs change.
    return true;
  }
}
