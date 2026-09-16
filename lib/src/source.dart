import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'data/event.dart';


extension CalendarDate on Date {
  Date get start => this;
  Date get stop => this;
}

extension CalendarWeek on Week {
  Date get start => mon;
  Date get stop => sun;
}

extension CalendarMonth on Month {
  Date get start => first.weekStart.date;
  Date get stop => last.weekEnd.date;
}


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

  void load(Date from, Date to) {
    if (cacheFrom == null || cacheTo == null) {
      _fetch(from, to);
      cacheFrom = from;
      cacheTo = to;
    } else if (from < cacheFrom! || to > cacheTo!) {
      shift(from, cacheFrom!);
      shift(cacheTo!, to);
      cacheFrom = from;
      cacheTo = to;
    }
  }

  void shift(Date from, Date to) {
    if (from == to) return;
    (from < to)
        ? _fetch(from, to)
        : _loose(to, from);
  }

  void clear() {
    cacheFrom = null;
    cacheTo = null;
    _cache.clear();
    _events.clear();
    notifyListeners();
  }

  void append(List<Event> others) => _events.addAll(others);

  Event? find(String id) => _events.where((e) => e.id == id).singleOrNull;

  static List<Event> sort(List<Event> events) {
    events.sort((a, b) {
      final startSort = a.start.compareTo(b.start);
      if (startSort != 0) return startSort;
      return b.duration.compareTo(a.duration);
    });
    return events;
  }

  List<Event> get events => _events;
  List<Date> get dates {
    final keys = _cache.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    return keys;
  }
  bool get built => cacheFrom != null && cacheTo != null;

  // ── Query pubbliche ─────────────────────────────────────────────────────

  List<Event> forDate(Date date) {
    load((date - cacheRange).toMonth.start, (date + cacheRange).toMonth.stop);
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
  }

  void _loose(Date from, Date to) {
    for (var date = from; date < to; date += 1) {
      _cache.remove(date);
    }
  }

  void _inject(Event event) {
    final events = event.expand(cacheFrom!, cacheTo!);
    for (final e in events) {
      for (final date in e.dates) {
        if (date < cacheFrom! || date >= cacheTo!) continue;
        sort(_cache[date]!..add(e));
      }
    }
  }

  void _cancel(Event event) {
    final id = event.id;
    for (var entry in _cache.entries) {
      entry.value.removeWhere((e) => (e.id == id) || (e.parentId == id));
    }
  }

  // ── Mutazioni ───────────────────────────────────────────────────────────

  void addEvent(Event event) {
    _events.add(event);
    _inject(event);
  }

  void setEvent(String id, Map<String, dynamic> data) {
    final event = _events.singleWhere((e) => e.id == id);
    _cancel(event);
    event.set(data);
    _inject(event);
  }

  void delEvent(String id) {
    final event = _events.singleWhere((e) => e.id == id);
    _events.remove(event);
    _cancel(event);
  }


  DateTime? hasBefore(DateTime datetime) {
    final dates = <DateTime>[];
    for (Event event in _events) {
      if (event.start.isBefore(datetime)) dates.add(event.start);
    }
    return (dates.isNotEmpty)
        ? dates.reduce((a, b) => a.isAfter(b) ? a : b).weekStart
        : null;
  }

  DateTime? hasAfter(DateTime datetime) {
    final dates = <DateTime>[];
    for (Event event in _events) {
      if (event.stop.isAfter(datetime)) dates.add(event.stop);
    }
    return (dates.isNotEmpty)
        ? dates.reduce((a, b) => a.isBefore(b) ? a : b).weekStart
        : null;
  }
}


class CalendarSource<T extends Event> extends CalendarEvents {
  CalendarSource({
    List<T>? events,
    super.cacheRange,
    this.label,
    bool visible = true,
  }) :  _visible = visible,
        super(events: events);

  final String? label;
  bool _visible;
  bool get visible => _visible;
  set visible(bool value) {
    if (_visible == value) return;
    _visible = value;
    notifyListeners();
  }

  @override
  List<T> get events => _events.cast<T>();

  @override
  T? find(String id) => super.find(id) as T;

  void set(List<T> events) => this..clear()..append(events);

  void insertEvent(T event, [bool notify = true]) {
    super.addEvent(event);
    if (notify) notifyListeners();
  }

  void modifyEvent(T event, [bool notify = true]) {
    super.setEvent(event.id!, event.get());
    if (notify) notifyListeners();
  }

  void removeEvent(T event, [bool notify = true]) {
    super.delEvent(event.id!);
    if (notify) notifyListeners();
  }
}


class CalendarSources<T extends Event> extends CalendarSource<T> {
  CalendarSources(this._sources) {
    for (final source in _sources) {
      source.addListener(notifyListeners);
    }
  }

  final Set<CalendarSource<T>> _sources;

  List<CalendarSource<T>> get sources => List.unmodifiable(_sources);
  Iterable<CalendarSource<T>> get _active => _sources.where((s) => s.visible);

  CalendarSource<T> source(String label) =>
      _sources.singleWhere((s) => s.label == label);

  void toggle(CalendarSource<T> source, [bool? value]) =>
      source.visible = value ?? !source.visible;

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(notifyListeners);
    }
    super.dispose();
  }

  // ── Query ───────────────────────────────────────────────────────────────

  @override
  List<T> get events => [for (final s in _active) ...s.events];

  @override
  List<Date> get dates {
    final keys = <Date>{for (final s in _active) ...s.dates}.toList();
    keys.sort((a, b) => a.compareTo(b));
    return keys;
  }

  @override
  bool get built => _active.every((s) => s.built);

  @override
  List<Event> forDate(Date date) => CalendarEvents.sort([
    for (final s in _active) ...s.forDate(date),
  ]);

  @override
  void load(Date from, Date to) {
    for (var s in _active) {
      s.load(from, to);
    }
  }

  @override
  void clear() {
    for (final s in _sources) {
      s.clear();
    }
    notifyListeners();
  }

  @override
  DateTime? hasBefore(DateTime datetime) {
    final all = [for (final s in _active) s.hasBefore(datetime)].nonNulls;
    return all.isEmpty ? null : all.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  DateTime? hasAfter(DateTime datetime) {
    final all = [for (final s in _active) s.hasAfter(datetime)].nonNulls;
    return all.isEmpty ? null : all.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  // ── Routing delle mutazioni ─────────────────────────────────────────────

  CalendarSource<T>? owner(String id) {
    for (final source in _sources) {
      if (source.events.any((e) => e.id == id)) return source;
    }
    return null;
  }

  @override
  T? find(String id) {
    for (final source in _sources) {
      final match = source.find(id);
      if (match != null) return match;
    }
    return null;
  }
}