import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../slots/slot_event.dart';
import '../slots/slot_layout.dart';
import '../slots/slot_modify.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../source.dart';
import '../../enums.dart';


class AgendaSlot extends StatelessWidget {
  const AgendaSlot({
    super.key,
    required this.date,
    required this.width,
    required this.callbacks,
  });

  final Date date;
  final double width;
  final CallbackScheme callbacks;

  List<SlotLayout> layouts(List<Event> events, double spanning) {
    final containers = <SlotLayout>[];
    for (int i = 0; i < events.length; i++) {
      containers.add(SlotLayout(
        event: events[i],
        container: Rect.fromLTWH(0.0, 0.0, width, spanning),
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
      child: Column(
        children: [
          for (var layout in layouts(events, 50.0))
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
