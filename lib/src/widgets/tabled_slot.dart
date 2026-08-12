import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../source.dart';
import 'tabled_metrics.dart';
import 'tabled_listed.dart';
import 'tabled_paged.dart';
import 'tabled_frame.dart';


class TabledSlot extends StatelessWidget {

  const TabledSlot({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.callbacks,
    required this.timeScheme,
    required this.dateScheme,
    required this.converter,
    this.offset = Offset.zero,
  });

  final Date date;
  final double width;
  final double? height;
  final CallbackScheme callbacks;
  final OffsetConverter converter;
  final DateScheme dateScheme;
  final TimeScheme? timeScheme;
  final Offset offset;
  double get frameWidth => width - offset.dx;
  double get frameHeight => (height ?? 0.0) - offset.dy;

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarEvents>();
    final space = frameWidth / dateScheme.count;
    return Stack(
      children: [
        if (height != null) TabledFrame(
          width: width,
          height: height!,
          offset: offset,
          timeScheme: timeScheme,
          dateScheme: dateScheme,
          onTap: (local, [_]) => callbacks.onFrameTap?.call(converter(date, local)),
          onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(converter(date, local)),
          onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(converter(date, local)),
        ),
        for (int i = dateScheme.beg; i < dateScheme.end; i++)
          Positioned(
            top: offset.dy,
            left: offset.dx + (i - dateScheme.beg) * space,
            child: Column(
              children: [
                (timeScheme != null && height != null)
                    ? TabledPaged(
                      date: date + i,
                      width: space,
                      height: height!,
                      timeScheme: timeScheme!,
                      callbacks: callbacks,
                    )
                    : TabledListed(
                      date: date + i,
                      width: space,
                      height: height,
                      callbacks: callbacks,
                    ),
              ],
            ),
          ),
      ],
    );
  }
}
