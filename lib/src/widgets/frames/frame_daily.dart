import 'package:flutter/material.dart';
import '../tools/painter_lines.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../enums.dart';


typedef OnTapCallback = void Function(int minute);


class DailyFrame extends StatelessWidget {

  const DailyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.timeScheme,
    // Interactive callback
    this.dailyTap,
  });

  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  // Interactive callback
  final OnTapCallback? dailyTap;

  void _onTapUp(TapUpDetails details) => dailyTap!(
      (details.localPosition.dy * timeScale).toInt()
  );

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final timeMargin = (config.time?.padding ?? 0.0) / 2;
    final timePainter = CustomPaint(
      size: Size.infinite,
      painter: LinesPainter(
        divisions: timeScheme.hours,
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
        positions: [0.0],
        lineStyle: config.line.style,
        lineColor: config.line.color,
        lineWidth: config.line.width,
        offset: config.line.offsetY,
        dashedSpace: config.line.dashedSpace,
        dashedWidth: config.line.dashedWidth,
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
          onTapUp: (dailyTap == null) ? null : _onTapUp,
          child: framePainter,
        )
    );
  }
}
