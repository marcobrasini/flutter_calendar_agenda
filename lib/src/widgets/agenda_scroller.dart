import 'package:calendar/src/config.dart';
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
    this.appbar = const [],
  });

  final Axis direction;
  final AgendaRegistry registry;
  final ScrollBuilder builder;
  final List<Widget> appbar;

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
  dynamic get _nextDate => widget.registry.indexer(recorded, _nextIndex);
  dynamic get _lastDate => widget.registry.indexer(recorded, _lastIndex);
  DateTime get recorded => _viewer.datetime;
  DateTime get scrolled => _controller.datetime;


  int? findNext() {
    final index = _nextIndex;
    final dates = _source.dates;
    while (dates.contains(_nextDate)) {
      _nextIndex++;
      for (Date date in _nextDate.iterate(widget.registry.dateScheme)) {
        if (_source.forDate(date).isNotEmpty) return _nextIndex;
      }
    }
    _nextIndex = index;
    return null;
  }

  int? findLast() {
    final index = _lastIndex;
    final dates = _source.dates;
    while (dates.contains(_lastDate)) {
      _lastIndex--;
      for (Date date in _lastDate.iterate(widget.registry.dateScheme)) {
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
    final config = CalendarConfig.of(context);
    if (_sequential && (!config.fixLastAnchor || !config.fixNextAnchor)) {
      context.watch<CalendarEvents>();
    }
    final centred = config.centred && widget.appbar.isEmpty;
    final showLastAnchor = config.fixLastAnchor || _source.hasBefore(_lastDate) != null;
    final showNextAnchor = config.fixNextAnchor || _source.hasAfter(_nextDate) != null;
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
        center: (centred) ? _centerKey : null,
        slivers: [
          ...widget.appbar,
          if (_sequential && showLastAnchor) SliverToBoxAdapter(
            child: GestureDetector(
              child: config.lastAnchorBuilder?.call(context) ?? Icon(Icons.keyboard_double_arrow_up),
              onTap: () => setState(() {
                findLast();
              }),
            ),
          ),
          if (centred) SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: (_sequential) ? _lastIndex.abs() : null,
                  (context, index) => _build(-(index + 1)),
            ),
          ),
          if (!centred) SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: (_sequential) ? 1 + _nextIndex - _lastIndex : null,
                  (context, index) => _build(_lastIndex + index),
            ),
          ),
          if (centred) SliverList(
            key: _centerKey,
            delegate: SliverChildBuilderDelegate(
              childCount: (_sequential) ? 1 + _nextIndex : null,
                  (context, index) => _build(index),
            ),
          ),
          if (_sequential && showNextAnchor) SliverToBoxAdapter(
            child: config.nextAnchorBuilder?.call(context) ?? IconButton(
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
