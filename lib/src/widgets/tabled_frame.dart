import 'package:flutter/material.dart';
import 'tools/painter_lines.dart';
import '../utils/schemes.dart';
import '../config.dart';
import '../enums.dart';
import '../const.dart';


class TabledFrame extends StatelessWidget {

  const TabledFrame({
    super.key,
    required this.width,
    required this.height,
    this.offset = Offset.zero,
    this.visible = true,
    this.dateScheme,
    this.timeScheme,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final double? width;
  final double? height;
  final Offset offset;
  final bool visible;
  final DateScheme? dateScheme;
  final TimeScheme? timeScheme;
  final FrameCallback? onTap;
  final FrameCallback? onDoubleTap;
  final FrameCallback? onLongPress;
  double get dateScale => dateScheme?.scale(width ?? 0.0) ?? double.nan;
  double get timeScale => timeScheme?.scale(height ?? 0.0) ?? double.nan;
  double get frameWidth => (width ?? double.infinity) - offset.dx;
  double get frameHeight => (height ?? double.infinity) - offset.dy;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: width,
      child: (visible) ? GestureDetector(
        onTapUp: (details) => onTap?.call(details.localPosition),
        onLongPressDown: (details) => onLongPress?.call(details.localPosition),
        onDoubleTapDown: (details) => onDoubleTap?.call(details.localPosition),
        child: Stack(
          children: [
            if (timeScheme != null || height != null) CustomPaint(
              size: Size.infinite,
              painter: LinesPainter(
                divisions: timeScheme?.count ?? 1,
                lineStyle: config.line.lineStyle,
                lineWidth: config.line.lineWidth,
                lineColor: config.line.lineColor ?? colors.outlineVariant,
                offset: offset + Offset(config.line.lineOffsetX, 0.0),
                dashedSpace: config.line.dashedSpace,
                dashedWidth: config.line.dashedWidth,
                direction: LineDirection.horizontal,
              ),
            ),
            if (dateScheme != null || width != null) CustomPaint(
              size: Size.infinite,
              painter: LinesPainter(
                divisions: dateScheme?.count ?? 1,
                lineStyle: config.line.lineStyle,
                lineWidth: config.line.lineWidth,
                lineColor: config.line.lineColor ?? colors.outlineVariant,
                offset: offset + Offset(0.0, config.line.lineOffsetY),
                dashedSpace: config.line.dashedSpace,
                dashedWidth: config.line.dashedWidth,
                direction: LineDirection.vertical,
              ),
            ),
          ],
        ),
      ) : null,
    );
  }
}
