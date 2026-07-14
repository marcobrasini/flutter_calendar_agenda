import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page_frame.dart';
import 'page_slot.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../modifier.dart';
import '../../source.dart';
import '../../config.dart';


class PageWidget extends StatelessWidget {

  const PageWidget({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.timeScheme,
    required this.dateScheme,
    required this.callbacks,
  });

  final Date date;
  final double width;
  final double height;
  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  double get dateScale => dateScheme.scale(width);
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;

  DateTime converter(Date date, Offset local) {
    final step = timeScheme.round;
    final days = (local.dx * dateScale).floor() + dateScheme.beg;
    final delta = (local.dy * timeScale / step).round() * step;
    final from = (date + days) & Time.fromHour(timeScheme.beg);
    return from.add(Duration(minutes: delta));
  }

  // void _onTapped(BuildContext context, Offset local) {
  //   final config = CalendarConfig.of(context)!;
  //   final start = converter(local);
  //   callbacks.onEventCreated?.call(Fixture(
  //     start: start,
  //     stop: start.add(config.event.duration),
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarEvents>();
    context.read<CalendarModifier>().attachConverter(converter);
    final config = CalendarConfig.of(context)!;
    final offset = config.view.indicatorRadius;
    final space = (width - offset) / dateScheme.count;
    return Stack(
      children: [
        PageFrame(
          width: width,
          height: height,
          timeScheme: timeScheme,
          dateScheme: dateScheme,
          onTap: (local, [_]) =>
              callbacks.onFrameTap?.call(converter(date, local)),
          onDoubleTap: (local, [_]) =>
              callbacks.onFrameDoubleTap?.call(converter(date, local)),
          onLongPress: (local, [_]) =>
              callbacks.onFrameLongPress?.call(converter(date, local)),
          // onCreate: (local, [_]) =>
          //     _onTapped(context, local),
        ),
        for (int i = dateScheme.beg; i < dateScheme.end; i++)
          Positioned(
            left: offset + (i - dateScheme.beg) * space,
            child: PageSlot(
              date: date + i,
              width: space,
              height: height,
              timeScheme: timeScheme,
              callbacks: callbacks,
              offset: Offset((i - dateScheme.beg) * space, 0.0),
            ),
          ),
      ],
    );
  }
}
