import 'package:flutter/material.dart';
import '../tools/painter_lines.dart';
import '../../config.dart';
import '../../mixin.dart';
import '../../enums.dart';


typedef OnTapCallback = void Function(int day, int minute);


class WeeklyFrame extends StatelessWidget with TimeScheme, DateScheme {

  const WeeklyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.header,
    required this.padding,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    // Interactive callback
    this.weeklyTap,
  });

  final double width;
  final double height;
  final Widget header;
  final double padding;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  double get dateScale => days / width;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  double get timeScale => minutes / height;
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
    final config = CalendarConfig.of(context)!;
    final timeMargin = (config.time?.padding ?? 0.0) / 2;
    final dateMargin = (config.date?.padding ?? 0.0) / 2;
    final hourPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: hours,
        lineStyle: config.line.style,
        lineColor: config.line.color,
        lineWidth: config.line.width,
        offset: config.line.offsetX - timeMargin,
        dashedSpace: config.line.dashedSpace,
        dashedWidth: config.line.dashedWidth,
        direction: LineDirection.horizontal,
      ),
    );
    final dayPainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: days,
        lineStyle: config.line.style,
        lineColor: config.line.color,
        lineWidth: config.line.width,
        offset: config.line.offsetY - dateMargin,
        dashedSpace: config.line.dashedSpace,
        dashedWidth: config.line.dashedWidth,
        direction: LineDirection.vertical,
      ),
    );
    final framePainter = Stack(
      children: [
        hourPainter,
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
              child: framePainter,
            )
          ),
        ),
      ],
    );
  }
}
