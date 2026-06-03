import 'package:calendar/src/const.dart';
import 'package:calendar/src/mixin.dart';
import 'package:flutter/material.dart';
import '../components/painter_lines.dart';
import '../../enums.dart';
import '../../utils/datetime.dart';


typedef OnTapCallback = void Function(int week, int day);


class MonthlyFrame extends StatelessWidget with DateScheme, WeekScheme {

  const MonthlyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.begWeek,
    required this.endWeek,
    required this.weekStep,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    // LinePainter attributes
    required this.lineStyle,
    required this.lineColor,
    required this.lineWidth,
    required this.lineOffsetX,
    required this.lineOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    // Interactive callback
    this.monthlyTap,
  });

  final double width;
  final double height;
  @override final int begWeek;
  @override final int endWeek;
  @override final int weekStep;
  double get weekScale => weeks / height;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  double get dateScale => days / width;
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  final OnTapCallback? monthlyTap;

  void _onTapUp(TapUpDetails details) {
    if (monthlyTap == null) return;
    final date = (details.localPosition.dx * dateScale).toInt();
    final week = (details.localPosition.dy * weekScale).toInt();
    monthlyTap!(week, date);
  }

  @override
  Widget build(BuildContext context) {
    final weekPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: weeks,
        lineStyle: lineStyle,
        lineColor: lineColor,
        lineWidth: lineWidth,
        offset: lineOffsetX,
        dashedSpace: dashedSpace,
        dashedWidth: dashedWidth,
        direction: LineDirection.horizontal,
      ),
    );
    final dayPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: days,
        lineStyle: lineStyle,
        lineColor: lineColor,
        lineWidth: lineWidth,
        offset: lineOffsetY,
        dashedSpace: dashedSpace,
        dashedWidth: dashedWidth,
        direction: LineDirection.vertical,
      ),
    );
    final linePainter = Stack(
      children: [
        weekPainter,
        dayPainter,
      ],
    );
    return SizedBox(
        height: height,
        width: width,
        child: GestureDetector(
          onTapUp: _onTapUp,
          child: linePainter,
        )
    );
  }
}
