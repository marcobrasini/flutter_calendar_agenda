import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../source.dart';
import '../modifier.dart';
import 'calendar_target.dart';
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
    this.offset = Offset.zero,
  });

  final Date date;
  final double width;
  final double height;
  final CallbackScheme callbacks;
  final DateScheme dateScheme;
  final TimeScheme? timeScheme;
  final Offset offset;
  double get frameWidth => width - offset.dx;
  double get frameHeight => height - offset.dy;
  Size get size => Size(width, height);

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarEvents>();
    final modifier = context.read<CalendarModifier>();
    final delegate = (timeScheme != null)
        ? SlotDropDelegate(date, timeScheme!, dateScheme)
        : TileDropDelegate(date, dateScheme);
    final space = frameWidth / dateScheme.count;
    return Stack(
      children: [
        TabledFrame(
          width: width,
          height: height,
          offset: offset,
          timeScheme: timeScheme,
          dateScheme: dateScheme,
          onTap: (local, [_]) => callbacks.onFrameTap?.call(delegate.at(local, size)),
          onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(delegate.at(local, size)),
          onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(delegate.at(local, size)),
        ),
        for (int i = dateScheme.beg; i < dateScheme.end; i++)
          Positioned(
            top: offset.dy,
            left: offset.dx + (i - dateScheme.beg) * space,
            child: Column(
              children: [
                (timeScheme != null)
                    ? DropWidget(
                      registry: modifier.registry,
                      delegate: SlotDropDelegate(date + i, timeScheme!),
                      child: TabledPaged(
                        date: date + i,
                        width: space,
                        height: height,
                        timeScheme: timeScheme!,
                        callbacks: callbacks,
                      ),
                    ) : DropWidget(
                      registry: modifier.registry,
                      delegate: TileDropDelegate(date + i),
                      child: TabledListed(
                        date: date + i,
                        width: space,
                        height: height,
                        callbacks: callbacks,
                      ),
                    )
              ],
            ),
          ),
      ],
    );
  }
}
