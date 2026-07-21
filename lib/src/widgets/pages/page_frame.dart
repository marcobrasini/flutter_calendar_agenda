import 'package:flutter/material.dart';
import '../tools/painter_lines.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../enums.dart';
import '../../const.dart';


class PageFrame extends StatelessWidget {

  const PageFrame({
    super.key,
    required this.width,
    required this.height,
    this.offset = 0.0,
    this.dateScheme,
    this.timeScheme,
    // Interactive callback
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onCreate,
  });

  final double width;
  final double height;
  final double offset;
  final DateScheme? dateScheme;
  final TimeScheme? timeScheme;
  double get dateScale => dateScheme?.scale(width) ?? double.nan;
  double get timeScale => timeScheme?.scale(height) ?? double.nan;
  // Interactive callback
  final FrameCallback? onTap;
  final FrameCallback? onDoubleTap;
  final FrameCallback? onLongPress;
  final FrameCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final dateMargin = (config.date?.padding ?? 0.0) / 2;
    final space = (width - offset) / (dateScheme?.count ?? 1);
    return SizedBox(
        height: height,
        width: width,
        child: GestureDetector(
          onTapUp: (details) => onTap?.call(details.localPosition),
          onLongPressDown: (details) => onLongPress?.call(details.localPosition),
          onDoubleTapDown: (details) => onDoubleTap?.call(details.localPosition),
          child: Stack(
            children: [
              if (timeScheme != null) CustomPaint(
                size: Size.infinite,
                painter: LinesPainter(
                  divisions: timeScheme!.count,
                  lineStyle: config.line.style,
                  lineColor: config.line.color,
                  lineWidth: config.line.width,
                  offset: config.line.offsetX,
                  dashedSpace: config.line.dashedSpace,
                  dashedWidth: config.line.dashedWidth,
                  direction: LineDirection.horizontal,
                ),
              ),
              if (dateScheme != null) CustomPaint(
                size: Size.infinite,
                painter: LinesPainter(
                  positions: [
                    for (int i = 0; i < dateScheme!.count; i++)
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
