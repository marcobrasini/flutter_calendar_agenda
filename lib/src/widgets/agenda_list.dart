import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'slots/slot_card.dart';
import 'tools/slot_date.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../context.dart';
import '../source.dart';
import '../config.dart';
import '../const.dart';


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
    final colors = Theme.of(context).colorScheme;
    final source = context.read<CalendarEvents>();
    final events = source.forDate(date);
    final cardMargin = config.date.textPadding;
    final dateWidth = context.dateOffset() + cardMargin;
    final cardWidth = width - dateWidth;
    final lineColor = config.line.color ?? colors.outlineVariant;
    final widgets = Column(
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
    );
    return (events.isNotEmpty) ? Column(
      children: [
        Divider(
          height: 0.0,
          color: lineColor,
        ),
        (config.showFrame) ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateSlot(
              date: date,
              dateFormat: config.date.format ?? defaultDateFormat,
              datePadding: config.date.textPadding,
              dateTextStyle: config.date.textStyle,
              dateBackground: config.date.background,
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
