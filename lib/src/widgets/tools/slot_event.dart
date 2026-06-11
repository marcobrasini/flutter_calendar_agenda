import 'package:calendar/src/const.dart';
import 'package:calendar/src/data/event.dart';
import 'package:flutter/material.dart';


class EventSlot extends StatelessWidget {

  const EventSlot({
    super.key,
    required this.event,
    required this.width,
    required this.height,
    this.padding = 4,
    this.radius = 4,
    this.textStyle,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Event event;
  final double width;
  final double height;
  final double radius;
  final double padding;
  final TextStyle? textStyle;
  final EventCallback? onTap;
  final EventCallback? onDoubleTap;
  final EventCallback? onLongPress;

  Widget content() => Text(
    event.subject,
    style: textStyle,
    overflow: TextOverflow.ellipsis,
    maxLines: textSlotLines,
  );

  Widget slot([double transparency = 1.0]) => Container(
    height: height,
    width: width,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: event.color.withAlpha((transparency * 255).toInt()),
    ),
    child: content(),
  );

  @override
  Widget build(BuildContext context) {
    return Draggable<Event>(
      data: event,
      childWhenDragging: slot(0.5),
      feedback: Material(
        color: Colors.transparent,
        child: slot(),
      ),
      child: slot(),
    );
  }
}

