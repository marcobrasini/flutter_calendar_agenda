import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools/pointer_date.dart';
import 'slots/slot_event.dart';
import 'slots/slot_layout.dart';
import 'slots/slot_modify.dart';
import 'slots/slot_string.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../data/event.dart';
import '../modifier.dart';
import '../source.dart';
import '../enums.dart';


class WidgetListed extends StatelessWidget {
  WidgetListed({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.callbacks,
  }) : template = SlotString(string: "", width: width, maxLines: 1);

  final Date date;
  final double width;
  final double? height;
  final CallbackScheme callbacks;
  final SlotString template;
  double get tileHeight => template.layout.height * 1.25;

  List<SlotLayout> layouts(List<Event> events) {
    final containers = <SlotLayout>[];
    for (int i = 0; i < events.length; i++) {
      containers.add(SlotLayout(
        event: events[i],
        container: Rect.fromLTWH(0.0, 0.0, width, tileHeight),
        tile: true,
      ));
    }
    return containers;
  }

  @override
  Widget build(BuildContext context) {
    final source = context.read<CalendarEvents>();
    final events = source.forDate(date);
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          DatePointer(date: date),
          for (var layout in layouts(events))
            SizedBox(
              width: layout.width,
              height: layout.height,
              child: ListedSlotEvent(
                  layout: layout,
                  callbacks: callbacks,
              ),
            )
        ],
      ),
    );
  }
}


class ListedSlotEvent extends StatelessWidget {
  const ListedSlotEvent({
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
    return GestureDetector(
      onLongPress: () {
        callbacks.onEventLongPress?.call(layout.event);
        modifier.take(layout, SlotAction.dragging);
        if (layout.isExpanded) modifier.start();
      },
      onTap: () {
        callbacks.onEventTap?.call(layout.event);
        modifier.end();
      },
      child: (slot.editing)
          ? const SizedBox.shrink()
          : SlotEvent(layout: layout),
    );
  }
}
