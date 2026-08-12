import 'package:calendar/src/config.dart';
import 'package:calendar/src/context.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/widgets/slots/slot_card.dart';
import 'package:calendar/src/widgets/tools/slot_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AgendaList extends StatelessWidget {
  const AgendaList({
    super.key,
    required this.date,
    required this.width,
    required this.callbacks,
  });

  final Date date;
  final double width;
  final CallbackScheme callbacks;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final source = context.read<CalendarEvents>();
    final events = source.forDate(date);
    final cardMargin = config.date?.padding ?? 8.0;
    final dateWidth = context.dateOffset() + cardMargin;
    final cardWidth = width - dateWidth;
    return (events.isNotEmpty) ? Column(
      children: [
        Divider(
          height: 0.0,
          color: config.line.color,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateSlot(
              date: date,
              dateFormat: "EEE\ndd",
              datePadding: cardMargin,
              width: dateWidth,
            ),
            Container(
              width: cardWidth,
              padding: EdgeInsets.only(
                  left: cardMargin, top: cardMargin, bottom: cardMargin
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: config.line.color),
                ),
              ),
              child: Column(
                children: [
                  for (final event in events)
                    SlotCard(
                      event: event,
                      width: cardWidth - cardMargin,
                      height: config.event.extent,
                      onEventSwipedLeft: callbacks.onEventSwipedLeft,
                      onEventSwipedRight: callbacks.onEventSwipedRight,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    ) : SizedBox.shrink();
  }
}
