import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/color.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../const.dart';
import 'slot_layout.dart';


typedef DragCallback = void Function(Event);
typedef EventBuilder = Widget Function(BuildContext);


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

  @override
  Widget build(BuildContext context) {
    final modifier = context.watch<CalendarModifier>();
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
            color: layout.event.color.dimmer(eventSlotLineDimmed),
            width: eventSlotLineWidth,
          ) : null,
          borderRadius: BorderRadius.circular(eventSlotRounded),
          color: layout.event.color.withAlpha(alpha),
        ),
        child: builder?.call(context) ?? Text(
          layout.event.subject,
        ),
      ),
    );
  }
}