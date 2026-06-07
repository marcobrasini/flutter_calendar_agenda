import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../tools/painter_lines.dart';
import '../../enums.dart';
import '../../utils/schemes.dart';


typedef OnTapCallback = void Function(int week, int day);


class MonthlyFrame extends StatelessWidget {

  const MonthlyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.header,
    required this.padding,
    required this.weekScheme,
    required this.dateScheme,
    // Interactive callback
    this.monthlyTap,
  });

  final double width;
  final double height;
  final Widget header;
  final double padding;
  final WeekScheme weekScheme;
  double get weekScale => weekScheme.scale(height);
  final DateScheme dateScheme;
  double get dateScale => dateScheme.scale(width);
  // Interactive callback
  final OnTapCallback? monthlyTap;

  void _onTapUp(TapUpDetails details) {
    if (monthlyTap == null) return;
    final date = (details.localPosition.dx * dateScale).toInt();
    final week = (details.localPosition.dy * weekScale).toInt();
    monthlyTap!(week, date);
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final dateMargin = (config.date?.padding ?? 0.0) / 2;
    final weekPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: weekScheme.count,
        lineStyle: config.line.style,
        lineColor: config.line.color,
        lineWidth: config.line.width,
        offset: config.line.offsetX,
        dashedSpace: config.line.dashedSpace,
        dashedWidth: config.line.dashedWidth,
        direction: LineDirection.horizontal,
      ),
    );
    final dayPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: dateScheme.count,
        lineStyle: config.line.style,
        lineColor: config.line.color,
        lineWidth: config.line.width,
        offset: config.line.offsetY - dateMargin,
        dashedSpace: config.line.dashedSpace,
        dashedWidth: config.line.dashedWidth,
        direction: LineDirection.vertical,
      ),
    );
    final linePainter = Stack(
      children: [
        weekPainter,
        dayPainter,
      ],
    );
    return Column(
      children: [
        if (config.view.showHeader) header,
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: padding,
          ),
          child: SizedBox(
            height: height,
            width: width,
            child: GestureDetector(
              onTapUp: _onTapUp,
              child: linePainter,
            )
          ),
        ),
      ],
    );
  }
}
