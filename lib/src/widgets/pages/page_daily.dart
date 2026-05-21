import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_daily.dart';
import '../../enums.dart';


class DailyPage extends StatefulWidget {
  // TimeHeader attributes
  final int fromHour;
  final int toHour;
  final int step;
  final double rate;
  final double? width;
  final double? height;
  final Color? background;
  final String timeFormat;
  final double? textPadding;
  final TextStyle? textStyle;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffset;
  final double? lineLength;
  final double? dashedWidth;
  final double? dashedSpace;
  final int timeRound;

  DailyPage({
    super.key,
    this.fromHour = 0,
    this.toHour = 24,
    this.step = 60,
    this.rate = 1.0,
    this.width,
    this.height,
    this.background,
    this.timeFormat = "HH:mm",
    this.textPadding,
    this.textStyle,
    Color? lineColor,
    this.lineStyle = LineStyle.solid,
    this.lineWidth = 1.0,
    this.lineOffset = 0.0,
    this.lineLength,
    this.dashedWidth,
    this.dashedSpace,
    this.timeRound = 1,
  }) : lineColor = lineColor ?? Colors.grey.shade300;

  @override
  State<DailyPage> createState() => _DailyPageState();
}


class _DailyPageState extends State<DailyPage> {

  double margin(BuildContext context) {
    final style = widget.textStyle ?? DefaultTextStyle.of(context).style;
    return style.fontSize! * (style.height ?? 1.5);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final offset = margin(context);
        final length = (widget.toHour - widget.fromHour) * 60;
        final height = (widget.height != null || widget.rate != 0)
            ? widget.height ?? length * widget.rate
            : constraints.maxHeight - offset;
        final width = widget.width;
        final timeHeader = TimeHeader(
          fromHour: widget.fromHour,
          toHour: widget.toHour,
          step: widget.step,
          offset: offset,
          height: height,
          width: width,
          background: widget.background,
          timeFormat: widget.timeFormat,
          textPadding: widget.textPadding,
          textStyle: widget.textStyle,
        );
        final dayFrame = DailyFrame(
          init: timeHeader.from,
          scale: length / height,
          width: width,
          height: height,
          positions: timeHeader.positions,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffset: widget.lineOffset - (widget.textPadding ?? 0)/2,
          lineLength: widget.lineLength,
          dashedSpace: widget.dashedSpace,
          dashedWidth: widget.dashedWidth,
          timeRound: widget.timeRound,
        );
        final dayPage = Row(
          children: [
            timeHeader,
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: offset / 2),
                child: dayFrame,
              ),
            ),
          ],
        );
        return SingleChildScrollView(child: dayPage);
      },
    );
  }
}

