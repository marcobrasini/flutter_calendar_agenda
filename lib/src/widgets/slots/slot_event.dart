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
          borderRadius: BorderRadius.circular(eventSlotRounded),
          border: (selected) ? Border.all(
            color: event.color.dimmer(eventSlotLineDimmed),
            width: eventSlotLineWidth,
          ) : null,
          color: event.color.withAlpha(alpha),
        ),
        child: Stack(
          children: [
            config.eventBuilder?.call(context, event) ?? Container(
              padding: EdgeInsets.only(
                bottom: (event.parentId != null) ? 3 * eventSlotPadding : 0.0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(eventSlotPadding),
                child: Text(event.subject,
                  style: config.event.textStyle,
                  maxLines: config.event.maxLines,
                  overflow: config.event.overflow,
                ),
              ),
            ),
            if (event.parentId != null) Positioned(
              left: eventSlotPadding,
              bottom: eventSlotPadding,
              child: Icon(
                (event.pattern == null) ? Icons.sync_disabled : Icons.sync,
                color: config.event.textStyle?.color,
                size: 3 * eventSlotPadding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}