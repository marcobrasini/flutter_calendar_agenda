import 'package:flutter/material.dart';
import '../tools/painter_lines.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../enums.dart';
import '../../const.dart';


class DailyFrame extends StatelessWidget {

  const DailyFrame({
    super.key,
    required this.width,
    required this.height,
    required this.timeScheme,
    // Interactive callback
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onCreate,
  });

  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  // Interactive callback
  final FrameCallback? onTap;
  final FrameCallback? onDoubleTap;
  final FrameCallback? onLongPress;
  final FrameCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    return SizedBox(
        height: height,
        width: width,
        child: GestureDetector(
          onTapUp: (details)  {
            if (config.event.createAt == GestureType.tap) {
              onCreate?.call(details.localPosition);
            }
            onTap?.call(details.localPosition);
          },
          onLongPressDown: (details) {
            if (config.event.createAt == GestureType.longPress) {
              onCreate?.call(details.localPosition);
            }
            onLongPress?.call(details.localPosition);
          },
          onDoubleTapDown: (details) {
            if (config.event.createAt == GestureType.doubleTap) {
              onCreate?.call(details.localPosition);
            }
            onDoubleTap?.call(details.localPosition);
          },
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
                  positions: [config.view.indicatorRadius],
                  lineStyle: config.line.style,
                  lineColor: config.line.color,
                  lineWidth: config.line.width,
                  offset: config.line.offsetY,
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
