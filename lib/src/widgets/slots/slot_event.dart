import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/color.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../context.dart';
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
    final modifier = context.read<CalendarModifier>();
    final dimmer = (context.colors.brightness == Brightness.light)
        ?  eventSlotLineDimmed
        : -eventSlotLineDimmed;
    final config = context.config;
    final eventConfig = config.eventConfig();
    final eventStyle = eventConfig.styleFor(event);
    final padding = eventConfig.eventPadding;
    final alpha = dragging ? eventDraggableSlotAlpha : 255;
    return Listener(
      onPointerDown: (pointerEvent) {
        if (event.isAllDay && !config.allDayDragging) return;
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(pointerEvent.position);
        modifier.enter(
            pointerEvent.pointer,
            pointerEvent.position,
            local + offset,
        );
      },
      child: Container(
        margin: EdgeInsetsGeometry.all(eventConfig.eventMargin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(eventConfig.eventRounded),
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
                bottom: (event.parentId != null) ? 4 * padding : 0.0,
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Text(event.subject,
                  style: eventStyle,
                  maxLines: eventConfig.maxLines,
                  overflow: eventConfig.overflow,
                ),
              ),
            ),
            if (event.parentId != null) Positioned(
              left: padding,
              bottom: padding,
              child: Icon(
                (event.pattern == null) ? Icons.sync_disabled : Icons.sync,
                color: eventStyle?.color,
                size: 4 * padding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}