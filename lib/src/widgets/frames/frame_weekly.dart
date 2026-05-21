import 'package:flutter/material.dart';
import '../painters/painter_lines.dart';
import '../../utils/datetime.dart';
import '../../enums.dart';


typedef OnTapCallback = void Function(int day, Time time);


class WeeklyFrame extends StatelessWidget {
  final double height;
  final double width;
  final int dateSlots;
  final int timeSlots;
  final double dateScale;
  final double timeScale;
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double? lineLength;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  final OnTapCallback? weeklyTap;

  const WeeklyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.dateSlots,
    required this.timeSlots,
    required this.dateScale,
    required this.timeScale,
    required this.lineColor,
    required this.lineStyle,
    required this.lineWidth,
    required this.lineOffsetX,
    required this.lineOffsetY,
    this.lineLength,
    this.dashedWidth,
    this.dashedSpace,
    this.weeklyTap,
  });

  // List<double> positionsX(double width) {
  //   final positionList = <double>[0.0];
  //   final delta = width / daySlots;
  //   for (int i = 0; i < daySlots; i++) {
  //     positionList.add(positionList[i] + delta);
  //   }
  //   return positionList;
  // }
  //
  // List<double> positionsY(double height) {
  //   final positionList = <double>[0.0];
  //   final delta = height / timeSlots;
  //   for (int i = 0; i < timeSlots; i++) {
  //     positionList.add(positionList[i] + delta);
  //   }
  //   return positionList;
  // }

  void _onTapUp(TapUpDetails details) {
    final minutes = (details.localPosition.dy * timeScale).toInt();
    final day = (details.localPosition.dx * dateScale).toInt();
    if (weeklyTap != null) weeklyTap!(day, Time(0, 0) + minutes);
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPainter = CustomPaint(
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
    final verticalPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: dateSlots,
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
        horizontalPainter,
        verticalPainter,
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
