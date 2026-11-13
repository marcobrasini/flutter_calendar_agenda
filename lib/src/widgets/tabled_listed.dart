import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools/slot_date.dart';
import 'slots/slot_event.dart';
import 'slots/slot_layout.dart';
import 'slots/slot_modify.dart';
import '../utils/datetime.dart';
import '../modifier.dart';
import '../context.dart';
import '../config.dart';
import '../const.dart';
import '../enums.dart';
import 'calendar_target.dart';
import 'tabled_metrics.dart';
import 'tabled_span.dart';

class TabledListed extends StatelessWidget {
  const TabledListed({
    super.key,
    required this.date,
    required this.metrics,
    this.filter,
    this.active,
    this.header = true,
  });

  final Date date;
  final TabledMetrics metrics;
  final MultiFilter? filter;
  final DateFilter? active;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final config = context.config;
    final modifier = context.read<CalendarModifier>();
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = metrics.dateBeg; i < metrics.dateEnd; i++)
              Expanded(
                child: DropWidget(
                  registry: modifier.registry,
                  delegate: TileDropDelegate(
                    date + i,
                    forceAllDay: config.allDayDragging,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header) Row(
              children: [
                for (int i = metrics.dateBeg; i < metrics.dateEnd; i++)
                  Expanded(
                    child: DateSlot(
                      date: date + i,
                      config: context.config.dateConfig(metrics.view),
                      active: active?.call(date + i) ?? true,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: TabledSpan(
                date: date + metrics.dateBeg,
                metrics: metrics,
                filter: filter,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ListedSlotEvent extends StatelessWidget {
  const ListedSlotEvent({super.key, required this.layout});

  final SlotLayout layout;

  bool draggable(CalendarConfig config) =>
      config.event.draggable?.call(layout.event) ?? config.eventDraggable;

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
