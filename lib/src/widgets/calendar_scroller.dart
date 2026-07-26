import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widget_slot.dart';
import '../metrics.dart';
import '../viewer.dart';
import '../enums.dart';
import '../const.dart';


typedef ScrollBuilder = WidgetSlot Function(GlobalKey, DateTime);


class CalendarScroller extends StatefulWidget {
  const CalendarScroller({
    super.key,
    required this.direction,
    required this.controller,
    required this.metrics,
    required this.builder,
  });

  final Axis direction;
  final CalendarController controller;
  final CalendarMetrics metrics;
  final ScrollBuilder builder;

  @override
  State<CalendarScroller> createState() => _CalendarScrollerState();
}

class _CalendarScrollerState extends State<CalendarScroller> {
  static final Key _centerKey = UniqueKey();
  late final CalendarViewer _viewer;
  late final SnapPhysics _physics;
  bool _snapping = false;

  DateTime get recorded => widget.metrics.indexer(_viewer.datetime, 0);
  DateTime get scrolled => widget.controller.datetime;

  Widget _build(int index) {
    final metric = widget.metrics.metric(index);
    final datetime = widget.metrics.indexer(scrolled, index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = metric.key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final snap = widget.metrics.snapper?.call(datetime) ?? true;
        final size = switch (widget.direction) {
          Axis.horizontal => box.size.width,
          Axis.vertical => box.size.height,
        };
        widget.metrics.set(index, size, snap);
      }
    });
    return widget.builder(metric.key, datetime);
  }

  void viewerUpdate(int index, DateTime datetime) {
    if (recorded == datetime || index == 0) return;
    if (index > 0) {
      while (recorded.isBefore(datetime)) {_viewer.next();}
    } else {
      while (recorded.isAfter(datetime)) {_viewer.last();}
    }
  }

  bool _scrolling(ScrollNotification notification) {
    if (_snapping) return false;
    final index = widget.metrics.snap(notification.metrics.pixels);
    final datetime = widget.metrics.indexer(scrolled, index);
    final offset = widget.metrics.offset(index);
    if (datetime != widget.metrics.indexer(scrolled, 0)) {
      viewerUpdate(index, datetime);
      if (notification is ScrollEndNotification) {
        _snapping = true;
        widget.controller.datetime = recorded;
        widget.controller.jumpTo(notification.metrics.pixels - offset);
        widget.metrics.shift(index);
        setState(() {});
        _snapping = false;
        return false;
      }
    }
    return false;
  }

  void _animate(CalendarSwipe swipe) {
    if (!widget.controller.hasClients) return;
    final snap = widget.metrics.swipe(swipe);
    if (snap != 0) {
      widget.controller.animateTo(
        widget.metrics.offset(snap),
        duration: viewSwipeDelay,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    _viewer = context.read<CalendarViewer>();
    _physics = SnapPhysics(metrics: widget.metrics);
    widget.controller.datetime = recorded;
    super.initState();
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
        controller: widget.controller,
        scrollDirection: widget.direction,
        cacheExtent: widget.metrics.caching,
        center: _centerKey,
        physics: _physics,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) => _build(-(i + 1)),
            ),
          ),
          SliverList(
            key: _centerKey,
            delegate: SliverChildBuilderDelegate(
                  (context, i) => _build(i),
            ),
          ),
        ],
      ),
    );
  }
}


class SnapPhysics extends ScrollPhysics {
  const SnapPhysics({super.parent, required this.metrics});
  final CalendarMetrics metrics;

  @override
  bool get allowImplicitScrolling => false;

  @override
  SnapPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapPhysics(
      parent: buildParent(ancestor),
      metrics: metrics,
    );
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final index = metrics.snap(position.pixels);
    final target = metrics.offset(index);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: toleranceFor(position),
      );
    }
    return null;
  }
}
