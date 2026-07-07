import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../enums.dart';
import 'slot_layout.dart';
import 'slot_string.dart';
import 'slot_event.dart';


class WeeklySlot extends StatelessWidget {
  const WeeklySlot({
    super.key,
    required this.width,
    required this.height,
    required this.events,
    required this.dateScheme,
    required this.timeScheme,
    required this.callbacks,
  });

  final double width;
  final double height;
  final List<List<Event>> events;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final DateScheme dateScheme;
  double get dateScale => dateScheme.scale(width);
  final CallbackScheme callbacks;

  int _yOf(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  List<SlotLayout> layouts(double padding) {
    final results = <SlotLayout>[];
    final space = width / dateScheme.count;
    for (int i = 0 ; i < dateScheme.count ; i++) {
      final containers = <SlotLayout>[];
      for (final event in events[i]) {
        final containerTop = _yOf(event) / timeScale;
        final containerHeight = event.duration.inMinutes / timeScale;
        final content = StringSlot(string: event.subject, width: space);
        containers.add(SlotLayout(
          event: event,
          container: Rect.fromLTWH(
              i * space, containerTop, space, containerHeight
          ),
          content: content.layout.height,
          padding: padding,
        ));
      }
      final dailyResults = SlotLayout.layouts(containers);
      results.addAll(dailyResults);
    }
    return results;
  }

  bool isModifying(CalendarModifier modifier, SlotLayout layout) =>
      modifier.layout?.event == layout.event && modifier.editing;

  bool isDragging(CalendarModifier modifier, SlotLayout layout) =>
      isModifying(modifier, layout) && modifier.action == SlotAction.dragging;

  bool isResizing(CalendarModifier modifier, SlotLayout layout) =>
      isModifying(modifier, layout) && modifier.action == SlotAction.resizing;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final modifier = context.watch<CalendarModifier>();
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          for (final layout in layouts(config.event.padding))
            AnimatedPositioned(
              key: ValueKey(layout.event.id),
              duration: const Duration(milliseconds: 200),
              left: (modifier.layout?.event == layout.event)
                  ? layout.container.left
                  : layout.left,
              top: layout.top,
              width: (modifier.layout?.event == layout.event)
                  ? layout.container.width
                  : layout.width,
              height: layout.container.height,
              onEnd: () => modifier.start(),
              child: GestureDetector(
                onDoubleTap: () {
                  callbacks.onEventDoubleTap?.call(layout.event);
                  modifier.take(layout, SlotAction.resizing);
                  if (layout.isExpanded) modifier.start();
                },
                onLongPress: () {
                  callbacks.onEventLongPress?.call(layout.event);
                  modifier.take(layout, SlotAction.dragging);
                  if (layout.isExpanded) modifier.start();
                },
                onTap: () {
                  callbacks.onEventTap?.call(layout.event);
                  modifier.end();
                },
                child: (isResizing(modifier, layout))
                    ? SizedBox.shrink()
                    : EventSlot(
                      layout: layout,
                      dragging: isDragging(modifier, layout),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}