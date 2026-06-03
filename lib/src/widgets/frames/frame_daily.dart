import 'package:flutter/material.dart';
import '../painters/painter_lines.dart';
import '../../utils/datetime.dart';
import '../../enums.dart';


typedef OnTapCallback = void Function(int minute);


class DailyFrame extends StatelessWidget {
  final double width;
  final double height;
  final int timeSlots;
  final double timeScale;
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffset;
  final double? dashedWidth;
  final double? dashedSpace;
  final OnTapCallback? dailyTap;

  const DailyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.timeSlots,
    required this.timeScale,
    required this.lineColor,
    required this.lineStyle,
    required this.lineWidth,
    required this.lineOffset,
    this.dashedWidth,
    this.dashedSpace,
    this.dailyTap,
  });

  void _onTapUp(TapUpDetails details) {
    if (dailyTap == null) return;
    final minutes = (details.localPosition.dy * timeScale).toInt();
    dailyTap!(minutes);
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
        offset: lineOffset,
        dashedSpace: dashedSpace,
        dashedWidth: dashedWidth,
        direction: LineDirection.horizontal,
      ),
    );
    final dayPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        positions: [0.0],
        lineStyle: lineStyle,
        lineColor: lineColor,
        lineWidth: lineWidth,
        offset: lineOffset,
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
