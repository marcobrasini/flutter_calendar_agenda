import 'package:calendar/src/data/event.dart';
import 'package:flutter/material.dart';


class EventSlot extends StatelessWidget {
  final Event event;
  final double width;
  final double height;
  final double radius;
  final double padding;
  final TextStyle? textStyle;

  const EventSlot({
    super.key,
    required this.event,
    required this.width,
    required this.height,
    this.padding = 4,
    this.radius = 4,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        maxLines: 1,
      ),
    );
  }
}

