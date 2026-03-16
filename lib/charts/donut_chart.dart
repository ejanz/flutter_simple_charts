import 'package:flutter/material.dart';
import 'package:flutter_simple_charts/utils/enums.dart';
import 'package:flutter_simple_charts/utils/lists.dart';
import 'package:flutter_simple_charts/utils/types.dart';
import 'dart:math' as math;

import 'package:touchable/touchable.dart';

class DonutChart extends StatelessWidget {
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

  final List<DataItem> dataset;

  final DatasetOrdering? datasetOrdering;

  final String title;

  final double? height;

  final double? width;

  final double maxWidth;

  final List<Color> customColors;

  final Color? backGroundColor;

  final bool showTitle;

  final bool showCenterText;

  final bool showLabels;

  final bool showLegend;

  final bool showLines;

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

class DonutChartPainter extends CustomPainter {
  final List<DataItem> dataset;

  final BuildContext context;

  final String title;

  final List<Color> customColors;

  final Color? backGroundColor;

  final bool showTitle;

  final bool showCenterText;

  final bool showLabels;

  final bool showLegend;

  final bool showLines;

  final Function onTap;

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

  void drawLines(Canvas canvas, Offset c, Offset p, Paint linePaint) {
    canvas.drawLine(c, p, linePaint);
  }

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
