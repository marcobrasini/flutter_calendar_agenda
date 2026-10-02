import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'slots/slot_event.dart';
import 'slots/slot_string.dart';
import 'slots/slot_layout.dart';
import 'slots/slot_modify.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../data/event.dart';
import '../modifier.dart';
import '../source.dart';
import '../config.dart';
import '../const.dart';
import '../enums.dart';


class TabledPaged extends StatelessWidget {
  const TabledPaged({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.timeScheme,
  });

  final Date date;
  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);

  int _yOf(Event event) {
    final from = Time.fromHour(timeScheme.beg);
    return event.start.difference(date & from).inMinutes;
  }

  List<SlotLayout> layouts(List<Event> events, double padding) {
    final containers = <SlotLayout>[];
    for (final event in events) {
      final slotTop = _yOf(event) / timeScale;
      final slotHeight = event.duration.inMinutes / timeScale;
      final content = SlotString(string: event.subject, width: width);
      containers.add(SlotLayout(
        event: event,
        container: Rect.fromLTWH(0.0, slotTop, width, slotHeight),
        content: content.layout.height,
        padding: padding,
      ));
    }
    final results = SlotLayout.layouts(containers);
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context).event;
    final source = context.read<CalendarEvents>();
    final events = source.forDate(date).where((e) => !e.isAllDay).toList();
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          for (final layout in layouts(events, config.eventPadding))
            Positioned(
              key: ValueKey(layout.event.hashCode),
              left: 0.0,
              right: 0.0,
              top: layout.top,
              height: layout.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PagedSlotEvent(
                    layout: layout,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


class PagedSlotEvent extends StatelessWidget {
  const PagedSlotEvent({
    required this.layout,
    super.key,
  });

  final SlotLayout layout;

  bool resizable(CalendarConfig config) =>
      config.event.resizable?.call(layout.event) ?? config.eventResizable;

  bool draggable(CalendarConfig config) =>
      config.event.draggable?.call(layout.event) ?? config.eventDraggable;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final callbacks = config.callbacks;
    final modifier = context.read<CalendarModifier>();
    final slot = context.select<CalendarModifier, SlotModifier>((modifier) {
      final selected = modifier.layout?.event == layout.event;
      return SlotModifier(
        selected: selected,
        editing: selected && modifier.editing,
        action: selected ? modifier.action : null,
        container: selected ? modifier.layout?.container : null,
      );
    });
    final container = slot.selected ? slot.container : null;
    return AnimatedPositioned(
      key: ValueKey(layout.event.id),
      duration: eventSlotDuration,
      top: 0.0,
      bottom: 0.0,
      left: (container?.left ?? layout.left),
      width: container?.width ?? layout.width,
      onEnd: (draggable(config) || resizable(config))
          ? () => modifier.start()
          : null,
      child: GestureDetector(
        onDoubleTap: () {
          callbacks.onEventDoubleTap?.call(layout.event);
          if (resizable(config)) {
            modifier.take(layout, SlotAction.resizing);
            if (layout.isExpanded) modifier.start();
          }
        },
        onLongPress: () {
          callbacks.onEventLongPress?.call(layout.event);
          if (draggable(config)) {
            modifier.take(layout, SlotAction.dragging);
            if (layout.isExpanded) modifier.start();
          }
        },
        onTap: () {
          callbacks.onEventTap?.call(layout.event);
          modifier.end();
        },
        child: (slot.editing && slot.action == SlotAction.resizing)
            ? const SizedBox.shrink()
            : SlotEvent(
              event: layout.event,
              offset: Offset(layout.left, 0.0),
              dragging: slot.editing && slot.action == SlotAction.dragging,
            ),
      ),
    );
  }
}
