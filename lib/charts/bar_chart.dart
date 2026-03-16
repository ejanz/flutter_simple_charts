import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/utils/enums.dart';
import 'package:flutter_simple_charts/utils/lists.dart';
import 'package:flutter_simple_charts/utils/types.dart';

import 'package:touchable/touchable.dart';

/// A stateless widget that displays a bar chart based on the provided dataset.
///
/// This widget supports customization options such as title, colors, labels, legend,
/// and ordering of the dataset. It uses a custom painter to render the chart.
class BarChart extends StatelessWidget {
  /// Creates a BarChart widget.
  ///
  /// [dataset] is the list of data items to display.
  /// [title] is the title of the chart.
  /// [showTitle] determines if the title is shown.
  /// [height] and [width] set the chart dimensions.
  /// [maxWidth] limits the maximum width of the chart.
  /// [customColors] provides colors for the bars.
  /// [backGroundColor] sets the background color.
  /// [showLabels], [showLegend], [showLines] control visibility of elements.
  /// [onBarTap] is a callback for bar taps.
  /// [datasetOrdering] specifies how to order the dataset.
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
    this.onBarTap = _defaultOnTap,
    this.datasetOrdering,
  });

  /// Default tap handler that does nothing.
  static void _defaultOnTap(DataItem barValue) {}

  /// The list of data items for the chart.
  final List<DataItem> dataset;

  /// The ordering mode for the dataset.
  final DatasetOrdering? datasetOrdering;

  /// The title of the chart.
  final String title;

  /// The height of the chart.
  final double? height;

  /// The width of the chart.
  final double? width;

  /// The maximum width of the chart.
  final double maxWidth;

  /// Custom colors for the bars.
  final List<Color> customColors;

  /// The background color of the chart.
  final Color? backGroundColor;

  /// Whether to show labels on the bars.
  final bool showTitle;

  /// Whether to show labels on the bars.
  final bool showLabels;

  /// Whether to show the legend.
  final bool showLegend;

  /// Whether to show grid lines.
  final bool showLines;

  /// Callback function when a bar is tapped.
  final Function(DataItem) onBarTap;

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
                  painter: BarChartPainter(
                    datasetOrdered,
                    context,
                    title: title,
                    customColors: customColors,
                    backGroundColor: backGroundColor,
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

/// A custom painter for rendering the bar chart.
///
/// This painter draws the bars, labels, title, legend, and grid lines based on the dataset.
class BarChartPainter extends CustomPainter {
  /// The list of data items to paint.
  final List<DataItem> dataset;

  /// The build context for theming.
  final BuildContext context;

  /// The title of the chart.
  final String title;

  /// Custom colors for the bars.
  final List<Color> customColors;

  /// The background color.
  final Color? backGroundColor;

  /// Whether to show the title.
  final bool showTitle;

  /// Whether to show labels.
  final bool showLabels;

  /// Whether to show the legend.
  final bool showLegend;

  /// Whether to show grid lines.
  final bool showLines;

  /// Callback for tap events.
  final Function onTap;

  /// Creates a BarChartPainter.
  ///
  /// [dataset] is the data to display.
  /// [context] is the build context.
  /// Other parameters control appearance and behavior.
  BarChartPainter(
    this.dataset,
    this.context, {
    this.title = '',
    required this.customColors,
    this.backGroundColor,
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
    );

    if (showLabels) {
      drawLabel(canvas, size, barWidth, maxHeight, dataset, greaterDataset);
    }

    if (showLegend) {
      drawLegend(canvas, size, dataset);
    }
  }

  /// Draws the grid lines on the chart.
  ///
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the canvas.
  /// [maxHeight] is the maximum height for the chart area.
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

  /// Draws the bars on the chart.
  ///
  /// [touchyCanvas] is the touchable canvas.
  /// [paint] is the paint for the bars.
  /// [size] is the canvas size.
  /// [barWidth] is the width of each bar.
  /// [maxHeight] is the maximum height.
  /// [dataset] is the data.
  /// [greaterDataset] is the item with the greatest value.
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
      paint.color = dataset[i].color ?? customColors[i];
      touchyCanvas.drawRect(
        Rect.fromPoints(Offset(x, barHeight), Offset(x + barWidth, maxHeight)),
        paint,
        onTapDown: (detail) => onTap(dataset[i]),
      );
    }
  }

  /// Draws labels on the bars.
  ///
  /// [canvas] is the canvas.
  /// [size] is the canvas size.
  /// [barWidth] is the bar width.
  /// [maxHeight] is the max height.
  /// [dataset] is the data.
  /// [greaterDataset] is the max value item.
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
        style: TextStyle(
          fontSize: 14,
          color: dataset[i].color ?? customColors[i],
        ),
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

  /// Draws the title of the chart.
  ///
  /// [canvas] is the canvas.
  /// [size] is the canvas size.
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

  /// Draws the legend for the chart.
  ///
  /// [canvas] is the canvas.
  /// [size] is the canvas size.
  /// [dataset] is the data.
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
        ..color = dataset[i].color ?? customColors[i];

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
