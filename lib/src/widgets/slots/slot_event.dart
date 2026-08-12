import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/color.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../config.dart';
import '../../const.dart';


class SlotEvent extends StatelessWidget {
  const SlotEvent({
    super.key,
    required this.event,
    this.offset = Offset.zero,
    this.selected = false,
    this.dragging = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Event event;
  final Offset offset;
  final bool selected;
  final bool dragging;
  final SlotCallback? onTap;
  final SlotCallback? onDoubleTap;
  final SlotCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final modifier = context.read<CalendarModifier>();
    final alpha = dragging ? eventDraggableSlotAlpha : 255;
    return Listener(
      onPointerDown: (pointerEvent) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(pointerEvent.position);
        modifier.enter(
            pointerEvent.pointer,
            pointerEvent.position,
            local + offset,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: (selected) ? Border.all(
            color: event.color.dimmer(eventSlotLineDimmed),
            width: eventSlotLineWidth,
          ) : null,
          borderRadius: BorderRadius.circular(eventSlotRounded),
          color: event.color.withAlpha(alpha),
        ),
        // TODO correct the recurrences icon for better visualization.
        child: Stack(
          children: [
            config.event.builder?.call(context, event) ?? Padding(
              padding: EdgeInsetsGeometry.all(eventSlotPadding),
              child: Text(event.subject,
                style: config.event.textStyle,
              ),
            ),
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