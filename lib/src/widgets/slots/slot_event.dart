import 'package:flutter/material.dart';
import '../../utils/color.dart';
import '../../data/event.dart';
import '../../const.dart';
import 'slot_layout.dart';


typedef DragCallback = void Function(Event);
typedef EventBuilder = Widget Function(BuildContext);


class EventSlot extends StatelessWidget {
  const EventSlot({
    super.key,
    required this.layout,
    this.builder,
    this.dragging = false,
    this.resizing = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final SlotLayout layout;
  final EventBuilder? builder;
  final bool dragging;
  final bool resizing;
  final EventCallback? onTap;
  final EventCallback? onDoubleTap;
  final EventCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final alpha = dragging ? eventDraggableSlotAlpha : 255;
    return Container(
      width: layout.container.width,
      height: layout.container.height,
      padding: EdgeInsetsGeometry.all(layout.padding),
      decoration: BoxDecoration(
        border: (resizing) ? Border.all(
          color: layout.event.color.dimmer(eventResizableLineDimmed),
          width: eventResizableLineWidth,
        ) : null,
        borderRadius: BorderRadius.circular(eventSlotRounded),
        color: layout.event.color.withAlpha(alpha),
      ),
      child: builder?.call(context) ?? Text(
        layout.event.subject,
      ),
    );
  }
}