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
    this.onCreate,
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
  final FrameCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final offset = config.view.indicatorRadius;
    final dateMargin = (config.date?.padding ?? 0.0) / 2;
    final space = (width - offset) / dateScheme.count;
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
                  positions: [
                    for (int i = 0; i < dateScheme.count; i++)
                      offset + i * space
                  ],
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
