import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/widgets/pages/page_slot.dart';
import 'package:calendar/src/widgets/slots/slot_event.dart';
import 'package:calendar/src/widgets/slots/slot_layout.dart';
import 'package:calendar/src/widgets/slots/slot_modify.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ScrollSlot extends StatelessWidget {
  const ScrollSlot({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.callbacks,
    this.offset = Offset.zero,
  });

  final Date date;
  final double width;
  final double height;
  final CallbackScheme callbacks;
  final Offset offset;

  List<SlotLayout> tiles(List<Event> events) {
    final layouts = <SlotLayout>[];
    for (final event in events) {
      final rect = Rect.fromLTWH(offset.dx, offset.dy, width, 20.0);
      layouts.add(SlotLayout(
        event: event,
        container: rect,
      ));
    }
    return layouts;
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
          for (var layout in tiles(events))
            SizedBox(
              width: layout.width,
              height: layout.height,
              child: ScrollEventTile(
                key: ValueKey(layout.event.hashCode),
                layout: layout,
                offset: offset,
                callbacks: callbacks,
              ),
            ),
        ],
      ),
    );
  }
}


class ScrollEventTile extends StatelessWidget {
  const ScrollEventTile({
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
    return GestureDetector(
        onDoubleTap: () {
          callbacks.onEventDoubleTap?.call(layout.event);
          modifier.end();
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
        child: SlotEvent(
          layout: layout,
          dragging: slot.editing && slot.action == SlotAction.dragging,
        ),
    );
  }
}
