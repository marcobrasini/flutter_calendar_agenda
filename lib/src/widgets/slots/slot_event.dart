import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/color.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../const.dart';
import 'slot_layout.dart';


class EventSlot extends StatelessWidget {
  const EventSlot({
    super.key,
    required this.layout,
    this.builder,
    this.selected = false,
    this.dragging = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final SlotLayout layout;
  final EventBuilder? builder;
  final bool selected;
  final bool dragging;
  final SlotCallback? onTap;
  final SlotCallback? onDoubleTap;
  final SlotCallback? onLongPress;

  Event get event => layout.event;

  @override
  Widget build(BuildContext context) {
    final modifier = context.read<CalendarModifier>();
    final alpha = dragging ? eventDraggableSlotAlpha : 255;
    return Listener(
      onPointerDown: (pointerEvent) {
        final box = context.findRenderObject() as RenderBox;
        modifier.enter(
            pointerEvent.pointer,
            pointerEvent.position,
            box.globalToLocal(pointerEvent.position)
        );
      },
      child: Container(
        padding: EdgeInsetsGeometry.all(eventSlotPadding),
        decoration: BoxDecoration(
          border: (selected) ? Border.all(
            color: event.color.dimmer(eventSlotLineDimmed),
            width: eventSlotLineWidth,
          ) : null,
          borderRadius: BorderRadius.circular(eventSlotRounded),
          color: event.color.withAlpha(alpha),
        ),
        child: Stack(
          children: [
            builder?.call(context, event) ?? Text(event.subject),
            if (event.parentId != null) Positioned(
              left: 0.0,
              bottom: 0.0,
              child: Icon(
                (event.pattern == null) ? Icons.sync_disabled : Icons.sync,
                size: 12.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}