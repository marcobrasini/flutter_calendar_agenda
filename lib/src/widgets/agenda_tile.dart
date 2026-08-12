import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../source.dart';
import '../const.dart';
import 'agenda_header.dart';
import 'agenda_list.dart';


class AgendaTile extends StatefulWidget {
  const AgendaTile({
    super.key,
    required this.width,
    required this.datetime,
    required this.callbacks,
    this.negligible = false,
    this.shrinkable = true,
  });

  final double width;
  final dynamic datetime;
  final CallbackScheme callbacks;
  final bool negligible;
  final bool shrinkable;

  @override
  State<AgendaTile> createState() => _AgendaTileState();
}

class _AgendaTileState extends State<AgendaTile> {
  bool _expanded = true;

  Date get start => widget.datetime.first;
  Date get stop => widget.datetime.last;
  int get count => stop % start;

  bool get isEmpty {
    final source = context.watch<CalendarEvents>();
    for (int i = 0; i < count; i++) {
      if (source.forDate(start + i).isNotEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.negligible && isEmpty) return SizedBox.shrink();
    return Column(
      children: [
        AgendaHeader(
          dateStart: start,
          dateStop: stop,
          onTap: widget.shrinkable
              ? () => setState(() => _expanded = !_expanded)
              : null,
        ),
        (_expanded) ? Column(
          children: [
            for (int i = 0; i < count; i++)
              AgendaList(
                date: start + i,
                width: widget.width,
                callbacks: widget.callbacks,
              ),
            if (isEmpty) const Padding(
              padding: EdgeInsets.all(textSlotPadding),
              child: Center(child: Text("No events")),
            ),
          ],
        ) : const SizedBox.shrink(),
      ],
    );
  }
}

