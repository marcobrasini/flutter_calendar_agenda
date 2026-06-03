import 'package:calendar/src/const.dart';
import 'package:calendar/src/data/event.dart';
import 'package:flutter/material.dart';


typedef EventTapCallback = void Function(Event event);


class EventSlot extends StatelessWidget {
  final Event event;
  final double width;
  final double height;
  final double radius;
  final double padding;
  final TextStyle? textStyle;
  final EventTapCallback? onTap;
  final EventTapCallback? onDoubleTap;
  final EventTapCallback? onLongPress;

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

  // List<Event> overlapping(Event event) => events.where((e) =>
  // e != event &&
  //     e.start.time < event.stop.time &&
  //     e.stop.time > event.start.time
  // ).toList();
  //
  // // Larghezza relativa considerando le sovrapposizioni (0.0 - 1.0)
  // double widthFactor(Event event) {
  //   final group = overlapping(event);
  //   return group.isEmpty ? 1.0 : 1.0 / (group.length + 1);
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(event),
      onDoubleTap: onDoubleTap == null ? null : () => onDoubleTap!(event),
      onLongPress: onLongPress == null ? null : () => onLongPress!(event),
      child: Container(
        height: height,
        width: width,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: event.color,
        ),
        child: Text(
          event.subject,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: eventMaxLines,
        ),
      ),
    );
  }
}

