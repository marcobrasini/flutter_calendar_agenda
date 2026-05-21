import 'package:flutter/material.dart';
import '../painters/painter_lines.dart';
import '../../utils/datetime.dart';
import '../../enums.dart';


class DailyFrame extends StatefulWidget {

  final Time init;
  final double scale;
  final List<double> positions;
  final double height;
  final double? width;
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffset;
  final double? lineLength;
  final double? dashedWidth;
  final double? dashedSpace;
  final int? timeRound;

  const DailyFrame({
    super.key,
    required this.init,
    required this.scale,
    this.width,
    required this.height,
    required this.positions,
    required this.lineColor,
    required this.lineStyle,
    required this.lineWidth,
    required this.lineOffset,
    this.lineLength,
    this.dashedWidth,
    this.dashedSpace,
    this.timeRound,
  });

  @override
  State<DailyFrame> createState() => _DailyFrameState();
}

class _DailyFrameState extends State<DailyFrame> {
  late Time time;

  void onTap(TapUpDetails details) {
    setState(() {
      final minutes = details.localPosition.dy * widget.scale;
      final tapped = widget.init + minutes.toInt();
      (widget.timeRound == null) 
          ? time = tapped
          : time = tapped.round(widget.timeRound!);
    });
  }

  @override
  void initState() {
    time = widget.init;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final linePainter = Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: LinesPainter(
            positions: widget.positions,
            lineStyle: widget.lineStyle,
            lineColor: widget.lineColor,
            lineWidth: widget.lineWidth,
            offset: widget.lineOffset,
            length: widget.lineLength,
            dashedSpace: widget.dashedSpace,
            dashedWidth: widget.dashedWidth,
            direction: LineDirection.horizontal,
          ),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: LinesPainter(
            positions: [0.0],
            lineStyle: widget.lineStyle,
            lineColor: widget.lineColor,
            lineWidth: widget.lineWidth,
            offset: widget.lineOffset,
            length: widget.lineLength,
            dashedSpace: widget.dashedSpace,
            dashedWidth: widget.dashedWidth,
            direction: LineDirection.vertical,
          ),
        )
      ],
    );
    return SizedBox(
        height: widget.height,
        width: widget.width,
        child: GestureDetector(
          onTapUp: onTap,
          child: linePainter,
        )
    );
  }
}
