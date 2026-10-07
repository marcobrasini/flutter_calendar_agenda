import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools/slot_date.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../picker.dart';
import '../config.dart';
import '../enums.dart';
import 'tabled_frame.dart';


class HeaderSlot extends StatelessWidget {

  const HeaderSlot({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.dateScheme,
    this.offset = Offset.zero,
  });

  final Date date;
  final double width;
  final double height;
  final DateScheme dateScheme;
  final Offset offset;
  double get frameWidth => width - offset.dx;
  double get frameHeight => height - offset.dy;
  double get space => frameWidth / dateScheme.count;
  Size get size => Size(width, height);

  static int _daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final picker = context.read<CalendarPicker>();
    final config = CalendarConfig.of(context);
    final picked = picker.viewer?.datetime;
    final column = (picked is DateTime) ? _daysBetween(date, picked) : null;
    final visible = column != null
        && column >= dateScheme.beg
        && column < dateScheme.end;
    final eventConfig = config.eventConfig();
    final dateConfig = config.dateConfig(picker.view);
    return Stack(
      children: [
        TabledFrame(
          key: ValueKey(date),
          width: width,
          height: height,
          offset: offset,
          visible: false,
          dateScheme: dateScheme,
        ),
        for (int i = dateScheme.beg; i < dateScheme.end; i++)
          Positioned(
            top: offset.dy,
            left: offset.dx + (i - dateScheme.beg) * space,
            child: SizedBox(
              width: space,
              height: frameHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => picker.pick(date + i),
                child: IgnorePointer(
                  child: DateSlot(
                    width: space,
                    height: frameHeight,
                    date: date + i,
                    config: dateConfig,
                  ),
                ),
              ),
            ),
          ),
        if (visible)
          AnimatedPositioned(
            key: const ValueKey('Picked'),
            duration: eventConfig.eventDuration,
            top: (picker.viewer?.view == CalendarView.daily)
                ? offset.dy
                : 0,
            left: (picker.viewer?.view == CalendarView.daily)
                ? offset.dx + (column - dateScheme.beg) * space
                : 0,
            width: (picker.viewer?.view == CalendarView.daily)
                ? space
                : width,
            height: height,
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: eventConfig.eventDuration,
                builder: (context, t, child) => Opacity(opacity: t, child: child),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.primary, width: 2.0),
                    borderRadius: BorderRadius.circular(config.event.eventRounded),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
