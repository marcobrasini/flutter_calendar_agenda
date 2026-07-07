import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../tools/painter_lines.dart';
import '../../utils/schemes.dart';
import '../../enums.dart';
import '../../const.dart';


class MonthlyFrame extends StatelessWidget {

  const MonthlyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.weekScheme,
    required this.dateScheme,
    // Interactive callback
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final double width;
  final double height;
  final WeekScheme weekScheme;
  double get weekScale => weekScheme.scale(height);
  final DateScheme dateScheme;
  double get dateScale => dateScheme.scale(width);
  // Interactive callback
  final FrameCallback? onTap;
  final FrameCallback? onDoubleTap;
  final FrameCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final dateMargin = (config.date?.padding ?? 0.0) / 2;
    return SizedBox(
      height: height,
      width: width,
      child: GestureDetector(
        onTapUp: (details) => onTap?.call(details.localPosition),
        onLongPressDown: (details) => onLongPress?.call(details.localPosition),
        onDoubleTapDown: (details) => onDoubleTap?.call(details.localPosition),
        child: Stack(
          children: [
            CustomPaint(
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
