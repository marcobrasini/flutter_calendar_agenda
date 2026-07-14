import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../frames/frame_daily.dart';
import '../slots/slot_page.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/fixture.dart';
import '../../modifier.dart';
import '../../source.dart';
import '../../config.dart';


class DailyPage extends StatelessWidget {

  const DailyPage({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.timeScheme,
    required this.callbacks,
  });

  final Date date;
  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;

  DateTime converter(Offset local) {
    final step = timeScheme.round;
    final minutes = (local.dy * timeScale / step).round() * step;
    final time = Time.fromHour(timeScheme.beg) + minutes;
    return date & time;
  }

  void _onTapped(BuildContext context, Offset local) {
    final config = CalendarConfig.of(context)!;
    final start = converter(local);
    callbacks.onEventCreated?.call(Fixture(
        start: start,
        stop: start.add(config.event.duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<CalendarModifier>().attachConverter(converter);
    context.watch<CalendarSource>();
    final config = CalendarConfig.of(context)!;
    final offset = config.view.indicatorRadius;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          DailyFrame(
            width: width,
            height: height,
            timeScheme: timeScheme,
            onTap: (local, [_]) => callbacks.onFrameTap?.call(converter(local)),
            onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(converter(local)),
            onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(converter(local)),
            onCreate: (local, [_]) => _onTapped(context, local),
          ),
          Positioned(
            left: offset,
            child: PageSlot(
              date: date,
              width: width - offset,
              height: height,
              timeScheme: timeScheme,
              callbacks: callbacks,
              offset: Offset.zero,
            ),
          ),
        ],
      ),
    );
  }
}
