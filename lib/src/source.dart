import 'data/event.dart';
import 'utils/datetime.dart';
import 'package:flutter/material.dart';


class CalendarEvents extends ChangeNotifier {
  CalendarEvents({
    List<Event>? events,
    this.cacheRange = 1,
  }) : _events = events ?? <Event>[];

  final List<Event> _events;
  final Map<Date, List<Event>> _cache = {};
  final int cacheRange;
  Date? cacheFrom;
  Date? cacheTo;

  void build(Date from, Date to) {
    if (cacheFrom == null || cacheTo == null) {
      _fetch(from, to);
    } else if (from < cacheFrom! || to > cacheTo!) {
      _fetch(from, to);
    }
  }

  void clear() {
    cacheFrom = null;
    cacheTo = null;
    _cache.clear();
    _events.clear();
  }

  void append(List<Event> others) => _events.addAll(others);

  Event find(String id) => _events.singleWhere((e) => e.id == id);

  List<Event> sort(List<Event> events) {
    events.sort((a, b) {
      final startSort = a.start.compareTo(b.start);
      if (startSort != 0) return startSort;
      return b.duration.compareTo(a.duration);
    });
    return events;
  }

  // ── Query pubbliche ─────────────────────────────────────────────────────

  List<Event> forDate(Date date) {
    return _cache[date] ?? [];
  }

  // ── Prefetch ────────────────────────────────────────────────────────────

  void _fetch(Date from, Date to) {
    final events = _events.expand((e) => e.expand(from, to)).toList();
    for (var date = from; date < to; date += 1) {
      _cache.putIfAbsent(date, () => sort(
          events.where((e) => e.range(date, date+1)).toList()
      ));
    }
    cacheFrom = from;
    cacheTo = to;
  }

  void _cancel(Event event) {
    final id = event.id;
    for (var entry in _cache.entries) {
      entry.value.removeWhere((e) => (e.id == id) || (e.parentId == id));
    }
  }

  void _inject(Event event) {
    final events = event.expand(cacheFrom!, cacheTo!);
    for (final e in events) {
      for (final date in e.dates) {
        if (date < cacheFrom! || date >= cacheTo!) continue;
        final list = _cache.putIfAbsent(date, () => <Event>[]);
        list.add(e);
        sort(list);
      }
    }
  }

  // ── Mutazioni ───────────────────────────────────────────────────────────

  void addEvent(Event event) {
    _events.add(event);
    _inject(event);
    notifyListeners();
  }

  void setEvent(String id, Map<String, dynamic> data) {
    final event = _events.singleWhere((e) => e.id == id);
    _cancel(event);
    event.set(data);
    _inject(event);
    notifyListeners();
  }

  void delEvent(String id) {
    final event = _events.singleWhere((e) => e.id == id);
    _events.remove(event);
    _cancel(event);
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
