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


class WidgetPaged extends StatelessWidget {
  const WidgetPaged({
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
    final config = CalendarConfig.of(context);
    final source = context.read<CalendarEvents>();
    final events = source.forDate(date);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          for (final layout in layouts(events, config.event.padding))
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
                    callbacks: callbacks,
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
    super.key,
    required this.layout,
    required this.callbacks,
  });

  final SlotLayout layout;
  final CallbackScheme callbacks;

  @override
  Widget build(BuildContext context) {
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
        child: (slot.editing && slot.action == SlotAction.resizing)
            ? const SizedBox.shrink()
            : SlotEvent(
          layout: layout,
          dragging: slot.editing && slot.action == SlotAction.dragging,
        ),
      ),
    );
  }
}
