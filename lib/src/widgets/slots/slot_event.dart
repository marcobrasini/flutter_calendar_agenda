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
    final scheme = Theme.of(context).colorScheme;
    final dimmer = (scheme.brightness == Brightness.light)
        ?  eventSlotLineDimmed
        : -eventSlotLineDimmed;
    final config = CalendarConfig.of(context);
    final modifier = context.read<CalendarModifier>();
    final alpha = dragging ? eventDraggableSlotAlpha : 255;
    final style = config.event.styleFor(event);
    final padding = config.event.padding ?? 0.0;
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
            color: event.color.dimmer(dimmer),
            width: eventSlotLineWidth,
          ) : null,
          color: event.color.withAlpha(alpha),
        ),
        child: Stack(
          children: [
            config.eventBuilder?.call(context, event) ?? Container(
              padding: EdgeInsets.only(
                bottom: (event.parentId != null) ? 6 * padding : 0.0,
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Text(event.subject,
                  style: style,
                  maxLines: config.event.maxLines,
                  overflow: config.event.overflow,
                ),
              ),
            ),
            if (event.parentId != null) Positioned(
              left: padding,
              bottom: padding,
              child: Icon(
                (event.pattern == null) ? Icons.sync_disabled : Icons.sync,
                color: style?.color,
                size: 6 * padding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}