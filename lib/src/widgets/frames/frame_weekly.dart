import 'package:flutter/material.dart';
import '../tools/painter_lines.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../enums.dart';
import '../../const.dart';


class WeeklyFrame extends StatelessWidget {

  const WeeklyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.dateScheme,
    required this.timeScheme,
    // Interactive callback
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final double width;
  final double height;
  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  double get dateScale => dateScheme.scale(width);
  double get timeScale => timeScheme.scale(height);
  // Interactive callback
  final FrameCallback? onTap;
  final FrameCallback? onDoubleTap;
  final FrameCallback? onLongPress;

  int minutes(Offset position) => (position.dy * timeScale).toInt();
  int days(Offset position) => (position.dx * dateScale).toInt();

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    // final timeMargin = (config.time?.padding ?? 0.0) / 2;
    final dateMargin = (config.date?.padding ?? 0.0) / 2;
    return SizedBox(
        height: height,
        width: width,
        child: GestureDetector(
          onTapUp: (details) => onTap?.call(
              days(details.localPosition),
              minutes(details.localPosition),
          ),
          onLongPressDown: (details) => onLongPress?.call(
              days(details.localPosition),
              minutes(details.localPosition),
          ),
          onDoubleTapDown: (details) => onDoubleTap?.call(
              days(details.localPosition),
              minutes(details.localPosition),
          ),
          child: Stack(
            children: [
              CustomPaint(
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
              ),
              CustomPaint(
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
              ),
            ],
          ),
        )
    );
  }
}
