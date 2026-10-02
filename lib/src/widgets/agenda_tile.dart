import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../context.dart';
import '../source.dart';
import '../const.dart';
import 'agenda_header.dart';
import 'agenda_list.dart';

class AgendaTile extends StatefulWidget {
  const AgendaTile({
    super.key,
    required this.width,
    required this.datetime,
    required this.dateScheme,
    this.onCollapse,
    this.onNeglect,
    this.until,
  });

  final double width;
  final dynamic datetime;
  final DateScheme? dateScheme;
  final VoidCallback? onCollapse;
  final VoidCallback? onNeglect;
  final Date? until;

  @override
  State<AgendaTile> createState() => _AgendaTileState();
}

class _AgendaTileState extends State<AgendaTile> {
  bool _expanded = true;

  bool get isEmpty {
    final source = context.watch<CalendarEvents>();
    for (Date date in widget.datetime.iterate(widget.dateScheme)) {
      if (source.forDate(date).isNotEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarEvents>();
    final forced = widget.datetime
        .iterate(widget.dateScheme)
        .contains(Date.now());
    if (!forced && context.config.negligibleAgenda && isEmpty) {
      widget.onNeglect?.call();
      return SizedBox.shrink();
    }
    return Column(
      children: [
        AgendaHeader(
          datetime: widget.datetime,
          dateScheme: widget.dateScheme,
          onTap: context.config.shrinkableAgenda
              ? () => setState(() {
                  if (_expanded) widget.onCollapse?.call();
                  _expanded = !_expanded;
                })
              : null,
        ),
        if (_expanded) ...[
          for (Date date in widget.datetime.iterate(widget.dateScheme))
            if (widget.until == null || date <= widget.until!)
              AgendaList(
                date: date,
                width: widget.width,
              ),
          if (isEmpty)
            context.config.emptyBuilder?.call(context) ??
                const Padding(
                  padding: EdgeInsets.all(textSlotPadding),
                  child: Center(child: Text("No events")),
                ),
        ],
      ],
    );
  }
}
