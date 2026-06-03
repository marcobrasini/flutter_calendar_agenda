import 'package:flutter/material.dart';
import '../painters/painter_lines.dart';
import '../../enums.dart';


typedef OnTapCallback = void Function(int day, int minute);


class WeeklyFrame extends StatelessWidget {
  final double width;
  final double height;
  final int daySlots;
  final int timeSlots;
  final double dayScale;
  final double timeScale;
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  final OnTapCallback? weeklyTap;

  const WeeklyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.daySlots,
    required this.timeSlots,
    required this.dayScale,
    required this.timeScale,
    required this.lineColor,
    required this.lineStyle,
    required this.lineWidth,
    required this.lineOffsetX,
    required this.lineOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    this.weeklyTap,
  });

  void _onTapUp(TapUpDetails details) {
    if (weeklyTap == null) return;
    final day = (details.localPosition.dx * dayScale).toInt();
    final minutes = (details.localPosition.dy * timeScale).toInt();
    weeklyTap!(day, minutes);
  }

  @override
  Widget build(BuildContext context) {
    final timePainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: timeSlots,
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
        divisions: daySlots,
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
