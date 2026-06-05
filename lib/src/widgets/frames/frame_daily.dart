import 'package:flutter/material.dart';
import '../components/painter_lines.dart';
import '../../enums.dart';
import '../../mixin.dart';


typedef OnTapCallback = void Function(int minute);


class DailyFrame extends StatelessWidget with TimeScheme {

  const DailyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.header,
    required this.padding,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    // LinePainter attributes
    required this.lineStyle,
    required this.lineColor,
    required this.lineWidth,
    required this.lineOffsetX,
    required this.lineOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    // Interactive callback
    this.dailyTap,
  });

  final double width;
  final double height;
  final Widget header;
  final double padding;
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
  final OnTapCallback? dailyTap;

  void _onTapUp(TapUpDetails details) => dailyTap!(
      (details.localPosition.dy * timeScale).toInt()
  );

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
        positions: [0.0],
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
    return Column(
      children: [
        header,
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: padding,
          ),
          child: SizedBox(
            height: height,
            width: width,
            child: GestureDetector(
              onTapUp: (dailyTap == null) ? null : _onTapUp,
              child: framePainter,
            )
          ),
        ),
      ],
    );
  }
}
