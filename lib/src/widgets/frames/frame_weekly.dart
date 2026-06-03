import 'package:calendar/src/mixin.dart';
import 'package:flutter/material.dart';
import '../components/painter_lines.dart';
import '../../enums.dart';


typedef OnTapCallback = void Function(int day, int minute);


class WeeklyFrame extends StatelessWidget with TimeScheme, DateScheme {

  const WeeklyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
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
    this.weeklyTap,
  });

  final double width;
  final double height;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  double get dateScale => days / width;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  double get timeScale => minutes / height;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  // Interactive callback
  final OnTapCallback? weeklyTap;

  void _onTapUp(TapUpDetails details) {
    if (weeklyTap == null) return;
    final day = (details.localPosition.dx * dateScale).toInt();
    final minutes = (details.localPosition.dy * timeScale).toInt();
    weeklyTap!(day, minutes);
  }

  @override
  Widget build(BuildContext context) {
    final timePainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: hours,
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
    final framePainter = Stack(
      children: [
        timePainter,
        dayPainter,
      ],
    );
    return SizedBox(
        height: height,
        width: width,
        child: GestureDetector(
          onTapUp: _onTapUp,
          child: framePainter,
        )
    );
  }
}
