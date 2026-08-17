import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../source.dart';
import '../viewer.dart';
import '../enums.dart';
import '../const.dart';
import 'agenda_registry.dart';
import 'agenda_tile.dart';


typedef ScrollBuilder = AgendaTile Function(DateTime, Date?);


class AgendaScroller extends StatefulWidget {
  const AgendaScroller({
    super.key,
    required this.direction,
    required this.registry,
    required this.builder,
  });

  final Axis direction;
  final AgendaRegistry registry;
  final ScrollBuilder builder;

  @override
  State<AgendaScroller> createState() => _AgendaScrollerState();
}

class _AgendaScrollerState extends State<AgendaScroller> {
  static final Key _centerKey = UniqueKey();
  late final CalendarViewer _viewer;
  late final CalendarEvents _source;
  late Date? _until;
  bool _snapping = false;
  CalendarController get _controller => _viewer.controller;
  CalendarScroll get _scroll => _controller.scroll;

  int _lastIndex = 0;
  int _nextIndex = 0;
  bool get _sequential => _scroll == CalendarScroll.sequential;
  bool get _continuous => _scroll == CalendarScroll.continuous;
  dynamic get _maxDate => widget.registry.indexer(recorded, _nextIndex);
  dynamic get _minDate => widget.registry.indexer(recorded, _lastIndex);
  DateTime get recorded => _viewer.datetime;
  DateTime get scrolled => _controller.datetime;


  int? findNext() {
    final index = _nextIndex;
    final dates = _source.dates;
    while (dates.contains(_maxDate)) {
      _nextIndex++;
      for (Date date in _maxDate.iterate(widget.registry.dateScheme)) {
        if (_source.forDate(date).isNotEmpty) return _nextIndex;
      }
    }
    _nextIndex = index;
    return null;
  }

  int? findLast() {
    final index = _lastIndex;
    final dates = _source.dates;
    while (dates.contains(_minDate)) {
      _lastIndex--;
      for (Date date in _minDate.iterate(widget.registry.dateScheme)) {
        if (_source.forDate(date).isNotEmpty) return _lastIndex;
      }
    }
    _lastIndex = index;
    return null;
  }

  Widget _build(int index) {
    final datetime = widget.registry.indexer(scrolled, index);
    return WidgetRegistry(
      datetime: datetime,
      registry: widget.registry,
      child: widget.builder(datetime, _until),
    );
  }

  bool _scrolling(ScrollNotification notification) {
    if (_snapping) return false;
    if (notification is ScrollEndNotification) {
      final point = widget.registry.snap(notification.metrics.pixels);
      if (point == null) return false;
      _snapping = true;
      _viewer.datetime = point.datetime;
      _snapping = false;
    }
    return false;
  }

  void _animate(CalendarSwipe swipe) {
    if (!_controller.hasClients) return;
    final snap = widget.registry.swipe(swipe);
    if (snap != null) {
      _controller.animateTo(
        snap.offset,
        duration: viewSwipeDelay,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _viewer = context.read<CalendarViewer>();
    _source = context.read<CalendarEvents>();
    _until = (_sequential) ? Date.now() : null;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarViewer>();
    if (_viewer.swiping != null) {
      final swipe = _viewer.swiping!;
      _viewer.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animate(swipe);
      });
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _scrolling,
      child: CustomScrollView(
        controller: _viewer.controller,
        scrollDirection: widget.direction,
        cacheExtent: widget.registry.caching,
        center: _centerKey,
        slivers: [
          if (_sequential) SliverToBoxAdapter(
            child: IconButton(
              icon: Icon(Icons.keyboard_double_arrow_up),
              onPressed: () => setState(() {
                findLast();
              }),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: (_sequential) ? _lastIndex.abs() : null,
                  (context, index) => _build(-(index + 1)),
            ),
          ),
          SliverList(
            key: _centerKey,
            delegate: SliverChildBuilderDelegate(
              childCount: (_sequential) ? 1 + _nextIndex : null,
                  (context, index) => _build(index),
            ),
          ),
          if (_sequential) SliverToBoxAdapter(
            child: IconButton(
              icon: Icon(Icons.keyboard_double_arrow_down),
              onPressed: () => setState(() {
                (_until != null) ? _until = null : findNext();
              }),
            ),
          ),
        ],
      ),
    );
  }
}
