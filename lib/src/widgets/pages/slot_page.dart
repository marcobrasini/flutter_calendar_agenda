import 'package:calendar/src/const.dart';
import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/tile_event.dart';
import 'package:flutter/material.dart';


class PageSlot extends StatefulWidget {
  const PageSlot({
    super.key,
    required this.date,
  });
  
  final Date date;

  @override
  State<PageSlot> createState() => _PageSlotState();
}

class _PageSlotState extends State<PageSlot> {
  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    final events = source.forDate(widget.date);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        return EventTile(event: events[index]);
      },
    );
  }
}
