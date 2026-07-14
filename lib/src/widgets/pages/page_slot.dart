import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../slots/slot_event.dart';
import '../slots/slot_string.dart';
import '../slots/slot_layout.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../source.dart';
import '../../config.dart';
import '../../const.dart';
import '../../enums.dart';


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
            Positioned(
              key: ValueKey(layout.event.id),
              left: 0.0,
              right: 0.0,
              top: layout.top,
              height: layout.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PagedEventSlot(
                    key: ValueKey(layout.event.id),
                    layout: layout,
                    offset: offset,
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
    final container = slot.selected ? slot.container : null;
    return AnimatedPositioned(
      key: ValueKey(layout.event.id),
      duration: eventSlotDuration,
      top: 0.0 - offset.dy,
      bottom: 0.0 - offset.dy,
      left: (container?.left ?? layout.left) - offset.dx,
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
            : EventSlot(
              layout: layout,
              dragging: slot.editing && slot.action == SlotAction.dragging,
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
