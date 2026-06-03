import 'event.dart';
import '../utils/datetime.dart';
import 'package:flutter/material.dart';


class Source extends ChangeNotifier {
  final List<Event> _events;
  final Map<String, List<Event>> _cache = {}; // solo chiavi 'd:yyyy-MM-dd'
  final int prefetchWindow;

  Source(this._events, {this.prefetchWindow = 1});

  // ── Cache per giorno ──────────────────────────────────────────────────────

  String _key(Date date) => 'd:$date';

  List<Event> _forDate(Date date) {
    return _cache.putIfAbsent(
      _key(date),
          () => _events.expand((e) => e.expand(date, date + 1)).toList(),
    );
  }

  // ── Query pubbliche ───────────────────────────────────────────────────────

  List<Event> forDate(Date date) {
    final result = _forDate(date);
    _prefetch([date - 1, date + 1]);
    return result;
  }

  List<Event> forWeek(Week week) {
    final days = List.generate(7, (i) => week.mon + i);
    final result = days.expand(_forDate).toList();
    _prefetch([week.mon - 1, week.sun + 1]);
    return result;
  }

  List<Event> forMonth(Month month) {
    final from = Date(month.year, month.month, 1);
    final days = List.generate(month.days, (i) => from + i);
    final result = days.expand(_forDate).toList();
    _prefetch([from - 1, from + month.days]);
    return result;
  }

  // ── Prefetch ──────────────────────────────────────────────────────────────

  void _prefetch(List<Date> dates) {
    Future.microtask(() {
      for (final date in dates) {
        _cache.putIfAbsent(
          _key(date),
              () => _events.expand((e) => e.expand(date, date + 1)).toList(),
        );
      }
    });
  }

  // ── Invalidazione ─────────────────────────────────────────────────────────

  void _invalidate(Event event) {
    final start = event.start.date;
    final stop = event.stop.date;
    final days = stop % start;
    for (int i = 0; i <= days; i++) {
      _cache.remove(_key(start + i));
    }
  }

  void invalidateAll() => _cache.clear();

  // ── Mutazioni ─────────────────────────────────────────────────────────────

  void addEvent(Event event) {
    _events.add(event);
    _invalidate(event);
    notifyListeners();
  }

  void delEvent(String id) {
    final event = _events.firstWhere((e) => e.id == id);
    _events.remove(event);
    _invalidate(event);
    notifyListeners();
  }

  void setEvent(String id, Map<String, dynamic> data) {
    final i = _events.indexWhere((e) => e.id == id);
    if (i == -1) return;
    _invalidate(_events[i]);
    _events[i].set(data);
    _invalidate(_events[i]);
    notifyListeners();
  }
}

class CalendarSource extends InheritedNotifier<Source> {
  const CalendarSource({
    super.key,
    required Source source,
    required super.child,
  }) : super(notifier: source);

  static Source of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<CalendarSource>();
    assert(s != null, 'No InheritedSource found in context');
    return s!.notifier!;
  }
}