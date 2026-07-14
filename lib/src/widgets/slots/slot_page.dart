import 'package:calendar/src/config.dart';
import 'package:calendar/src/const.dart';
import 'package:calendar/src/source.dart';
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


class PageSlot extends StatelessWidget {
  const PageSlot({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.timeScheme,
    required this.callbacks,
    this.offset = Offset.zero,
  });

  final Date date;
  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;
  final Offset offset;

  int _yOf(Event event) {
    final from = Time.fromHour(timeScheme.beg);
    return event.start.difference(date & from).inMinutes;
  }

  List<SlotLayout> layouts(List<Event> events, double padding) {
    final containers = <SlotLayout>[];
    for (final event in events) {
      final slotTop = _yOf(event) / timeScale;
      final slotHeight = event.duration.inMinutes / timeScale;
      final content = StringSlot(string: event.subject, width: width);
      containers.add(SlotLayout(
        event: event,
        container: Rect.fromLTWH(offset.dx, offset.dy + slotTop, width, slotHeight),
        content: content.layout.height,
        padding: padding,
      ));
    }
    final results = SlotLayout.layouts(containers);
    return results;
  }
  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final source = context.read<CalendarSource>();
    final events = source.forDate(date);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          for (final layout in layouts(events, config.event.padding))
            PagedEventSlot(
              key: ValueKey(layout.event.id),
              layout: layout,
              offset: offset,
              callbacks: callbacks,
            ),
        ],
      ),
    );
  }
}


class PagedEventSlot extends StatelessWidget {
  const PagedEventSlot({
    super.key,
    required this.offset,
    required this.layout,
    required this.callbacks,
  });

  final Offset offset;
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

    final isDragging = slot.editing && slot.action == SlotAction.dragging;
    final isResizing = slot.editing && slot.action == SlotAction.resizing;

    final container = slot.selected ? slot.container : null;

    return AnimatedPositioned(
      duration: eventSlotDuration,
      left: (container?.left ?? layout.left) - offset.dx,
      top: layout.top - offset.dy,
      width: container?.width ?? layout.width,
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
        child: isResizing
            ? const SizedBox.shrink()
            : EventSlot(
          layout: layout,
          dragging: isDragging,
        ),
      ),
    );
  }
}


@immutable
class SlotModifier {
  const SlotModifier({
    required this.selected,
    required this.editing,
    required this.container,
    required this.action,
  });

  final bool selected;
  final bool editing;
  final Rect? container;
  final SlotAction? action;

  @override
  bool operator ==(Object other) => identical(this, other) || (
      other is SlotModifier
          && other.selected == selected
          && other.editing == editing
          && other.action == action
          && other.container == container);

  @override
  int get hashCode => Object.hash(selected, editing, action, container);
}
