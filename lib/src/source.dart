import 'data/event.dart';
import 'utils/datetime.dart';
import 'package:flutter/material.dart';


class CalendarEvents extends ChangeNotifier {
  CalendarEvents({
    List<Event>? events,
    this.cacheRange = 1,
  }) : _events = events ?? <Event>[];

  final List<Event> _events;
  final Map<String, List<Event>> cache = {};
  final int cacheRange;

  void clear() => _events.clear();
  void append(List<Event> others) => _events.addAll(others);

  Event find(String id) => _events.singleWhere((e) => e.id == id);

  // ── Cache per giorno ────────────────────────────────────────────────────

  String _key(Date date) => 'd:$date';

  List<Event> _forDate(Date date) {
    return cache.putIfAbsent(
      _key(date),
          () => _events.expand((e) => e.expand(date, date + 1).cast<Event>()).toList()
        ..sort((a, b) {
          final startSort = a.start.compareTo(b.start);
          if (startSort != 0) return startSort;
          return b.duration.compareTo(a.duration);
        }),
    );
  }
  //
  // List<Event> _range(Date start, Date stop) {
  //   final data = events.expand((e) => e.expand(start, stop).cast<Event>()).toList();
  //   return cache.putIfAbsent(
  //     _key(date),
  //         () => events.expand((e) => e.expand(start, stop).cast<Event>()).toList()
  //       ..sort((a, b) {
  //         final startSort = a.start.compareTo(b.start);
  //         if (startSort != 0) return startSort;
  //         return b.duration.compareTo(a.duration);
  //       }),
  //   );
  // }

  // ── Query pubbliche ─────────────────────────────────────────────────────

  List<Event> forDate(Date date) {
    final result = _forDate(date);
    _prefetch([date - cacheRange, date + cacheRange]);
    return result;
  }

  List<Event> forWeek(Week week) {
    final days = List.generate(7, (i) => week.mon + i);
    final result = days.expand(_forDate).toList();
    _prefetch([(week - 1).mon, (week + 1).sun]);
    return result;
  }

  List<Event> forMonth(Month month) {
    final from = Date(month.year, month.month, 1);
    final days = List.generate(month.days, (i) => from + i);
    final result = days.expand(_forDate).toList();
    _prefetch([from - 1, from + month.days]);
    return result;
  }

  // ── Prefetch ────────────────────────────────────────────────────────────

  void _prefetch(List<Date> dates) {
    Future.microtask(() {
      for (final date in dates) {
        cache.putIfAbsent(
          _key(date),
              () => _events.expand((e) => e.expand(date, date + 1).cast<Event>()).toList(),
        );
      }
    });
  }

  // ── Invalidazione ───────────────────────────────────────────────────────

  void _invalidate(Event event) {
    final id = event.id;
    final invalidate = <String>{};
    for (final entry in cache.entries) {
      if (entry.value.any((e) => (e.id == id) || (e.parentId == id))) {
        invalidate.add(entry.key);
      }
    }
    for (final key in invalidate) {
      cache.remove(key);
    }
  }

  void _invalidateDates(Date start, Date stop) {
    final days = stop % start;
    for (int i = 0; i <= days; i++) {
      cache.remove(_key(start + i));
    }
  }

  void invalidateAll() => cache.clear();

  // ── Mutazioni ───────────────────────────────────────────────────────────

  void addEvent(Event event) {
    _events.add(event);
    invalidateAll();
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
    invalidateAll();
    _events[i].set(data);
    notifyListeners();
  }
}

class CalendarSource<T extends Event> extends CalendarEvents {
  CalendarSource({List<T>? events, super.cacheRange})
      : super(events: events);

  List<T> get events => _events.cast<T>();

  @override
  T find(String id) => super.find(id) as T;

  void insertEvent(T event) => super.addEvent(event);
  void modifyEvent(T event) => super.setEvent(event.id!, event.get());
  void removeEvent(T event) => super.delEvent(event.id!);
}