import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'slots/slot_event.dart';
import 'slots/slot_layout.dart';
import 'slots/slot_modify.dart';
import '../utils/datetime.dart';
import '../data/event.dart';
import '../modifier.dart';
import '../context.dart';
import '../source.dart';
import '../config.dart';
import '../const.dart';
import '../enums.dart';


class TabledListed extends StatelessWidget {
  const TabledListed({
    super.key,
    required this.date,
    required this.width,
    this.height,
    this.filter,
  });

  final Date date;
  final double width;
  final double? height;
  final EditEvent? filter;

  List<SlotLayout> layouts(List<Event> events, double tileHeight) => [
    for (final event in events)
      SlotLayout(
        event: event,
        container: Rect.fromLTWH(0.0, 0.0, width, tileHeight),
        tile: true,
      )
  ];

  @override
  Widget build(BuildContext context) {
    final tileHeight = context.tileHeight();
    final source = context.read<CalendarEvents>();
    final events = source.forDate(date).where(filter ?? (_) => true).toList();
    return SizedBox(
      width: width,
      height: height,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0.0,
        maxHeight: double.infinity,
        fit: OverflowBoxFit.deferToChild,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var layout in layouts(events, tileHeight))
              SizedBox(
                width: layout.width,
                height: layout.height,
                child: ListedSlotEvent(layout: layout),
              )
          ],
        ),
      ),
    );
  }
}


class ListedSlotEvent extends StatelessWidget {
  const ListedSlotEvent({
    super.key,
    required this.layout,
  });

  final SlotLayout layout;

  bool draggable(CalendarConfig config) =>
      config.event.draggable?.call(layout.event) ?? config.eventDraggable;

  // @override
  // Widget build(BuildContext context) {
  //   final callbacks = context.config.callbacks;
  //   final modifier = context.read<CalendarModifier>();
  //   final slot = context.select<CalendarModifier, SlotModifier>((modifier) {
  //     final selected = modifier.layout?.event == layout.event;
  //     return SlotModifier(
  //       selected: selected,
  //       editing: selected && modifier.editing,
  //       action: selected ? modifier.action : null,
  //       container: selected ? modifier.layout?.container : null,
  //     );
  //   });
  //   return GestureDetector(
  //     onLongPress: () {
  //       callbacks.onEventLongPress?.call(layout.event);
  //       modifier.take(layout, SlotAction.dragging);
  //       if (layout.isExpanded) modifier.start();
  //     },
  //     onTap: () {
  //       callbacks.onEventTap?.call(layout.event);
  //       modifier.end();
  //     },
  //     child: (slot.editing)
  //         ? const SizedBox.shrink()
  //         : SlotEvent(event: layout.event),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final config = context.config;
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
    return GestureDetector(
      onLongPress: () {
        callbacks.onEventLongPress?.call(layout.event);
        if (draggable(config)) {
          modifier.take(layout, SlotAction.dragging);
          modifier.start();
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
    );
  }
}
