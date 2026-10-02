import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'slots/slot_card.dart';
import 'tools/slot_date.dart';
import '../utils/datetime.dart';
import '../context.dart';
import '../viewer.dart';
import '../source.dart';


class AgendaList extends StatelessWidget {
  const AgendaList({
    super.key,
    required this.date,
    required this.width,
  });

  final Date date;
  final double width;

  @override
  Widget build(BuildContext context) {
    final view = context.read<CalendarViewer>().view;
    final source = context.read<CalendarEvents>();
    final events = source.forDate(date);
    final callbacks = context.config.callbacks;
    final eventConfig = context.config.event;
    final lineConfig = context.config.line;
    final dateConfig = context.config.dateConfig(view);
    final cardMargin = dateConfig.textPadding;
    final dateWidth = context.dateOffset(view) + cardMargin;
    final cardWidth = width - dateWidth;
    final lineColor = lineConfig.color ?? context.colors.outlineVariant;
    final widgets = Column(
      children: [
        for (final event in events)
          SlotCard(
            event: event,
            width: cardWidth - cardMargin,
            height: eventConfig.extent,
            onEventSwipedLeft: callbacks.onEventSwipedLeft,
            onEventSwipedRight: callbacks.onEventSwipedRight,
          ),
      ],
    );
    return (events.isNotEmpty) ? Column(
      children: [
        Divider(
          height: 0.0,
          color: lineColor,
        ),
        (context.config.showFrame) ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateSlot(
              date: date,
              config: dateConfig,
              width: dateWidth,
            ),
            Container(
              width: cardWidth,
              padding: EdgeInsets.only(
                left: cardMargin, top: cardMargin, bottom: cardMargin,
              ),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: lineColor,)),
              ),
              child: widgets,
            ),
          ],
        ) : widgets,
      ],
    ) : SizedBox.shrink();
  }
}
