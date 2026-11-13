import 'package:flutter/material.dart';
import 'package:flutter_calendar_agenda/src/widgets/tabled_metrics.dart';
import 'package:provider/provider.dart';
import 'slots/slot_layout.dart';
import 'slots/slot_span.dart';
import '../utils/datetime.dart';
import '../data/event.dart';
import '../context.dart';
import '../source.dart';
import '../const.dart';
import 'tabled_listed.dart';

Object _keyOf(Event e) => (e.id, e.start);

List<SlotSpan> layoutSpans(
  CalendarEvents source,
  Date date,
  int count, {
  MultiFilter? filter,
}) {
  final spans = <Object, SlotSpan>{};
  for (int i = 0; i < count; i++) {
    for (final e in source.forDate(date + i)) {
      if (filter?.call(e) ?? true) {
        spans.putIfAbsent(_keyOf(e), () => SlotSpan(e, date));
      }
    }
  }
  // sort spanning by beginning, length, start
  if (spans.isEmpty) return const [];
  final list = spans.values.toList()
    ..sort((a, b) {
      final c = a.beg.compareTo(b.beg);
      if (c != 0) return c;
      final l = b.length.compareTo(a.length);
      if (l != 0) return l;
      return a.event.start.compareTo(b.event.start);
    });
  // order spanning in lanes
  final laneEnds = <int>[];
  for (final s in list) {
    int lane = laneEnds.indexWhere((end) => end < s.beg);
    if (lane < 0) {
      lane = laneEnds.length;
      laneEnds.add(s.end);
    } else {
      laneEnds[lane] = s.end;
    }
    s.lane = lane;
  }
  return list;
}

int spanLanes(
  CalendarEvents source,
  Date first,
  int count, {
  MultiFilter? filter,
}) {
  int lanes = 0;
  for (final s in layoutSpans(source, first, count, filter: filter)) {
    if (s.lane >= lanes) lanes = s.lane + 1;
  }
  return lanes;
}

class TabledSpan extends StatelessWidget {
  const TabledSpan({
    super.key,
    required this.date,
    required this.metrics,
    this.filter,
  });

  final Date date;
  final TabledMetrics metrics;
  final MultiFilter? filter;

  int get count => metrics.dateCount;
  double get width => metrics.width;
  double get space => width / count;

  @override
  Widget build(BuildContext context) {
    final tileHeight = context.tileHeight();
    final source = context.watch<CalendarEvents>();
    final spans = layoutSpans(source, date, count, filter: filter);
    if (spans.isEmpty) return const SizedBox.shrink();
    final lanes = spans.fold<int>(0, (m, s) => s.lane >= m ? s.lane + 1 : m);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = constraints.maxHeight.isFinite
            ? (constraints.maxHeight / tileHeight).floor()
            : lanes;
        final overflow = lanes > fit;
        final limit = overflow ? (fit - 1).clamp(0, lanes) : lanes;
        final hidden = List<int>.filled(count, 0);
        final children = <Widget>[];
        for (final s in spans) {
          if (s.lane >= limit) {
            for (int i = s.beg; i <= s.end; i++) {
              if (i >= 0 && i < count) hidden[i]++;
            }
            continue;
          }
          final width = s.length * space;
          children.add(
            Positioned(
              key: ValueKey(_keyOf(s.event)),
              left: s.beg * space,
              width: width,
              top: s.lane * tileHeight,
              height: tileHeight,
              child: ListedSlotEvent(
                layout: SlotLayout(
                  event: s.event,
                  container: Rect.fromLTWH(0.0, 0.0, width, tileHeight),
                  tile: true,
                ),
              ),
            ),
          );
        }
        if (overflow) {
          for (int i = 0; i < count; i++) {
            if (hidden[i] == 0) continue;
            children.add(
              Positioned(
                left: i * space,
                width: space,
                top: limit * tileHeight,
                height: tileHeight,
                child: Center(child: Text('+${hidden[i]}')),
              ),
            );
          }
        }
        return ClipRect(child: Stack(children: children));
      },
    );
  }
}
