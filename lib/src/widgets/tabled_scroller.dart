import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewer.dart';
import '../enums.dart';
import '../const.dart';
import 'tabled_slot.dart';
import 'tabled_metrics.dart';


typedef ScrollBuilder = TabledSlot Function(GlobalKey, DateTime);


class TabledScroller extends StatefulWidget {
  const TabledScroller({
    super.key,
    required this.direction,
    required this.metrics,
    required this.builder,
  });

  final Axis direction;
  final TabledMetrics metrics;
  final ScrollBuilder builder;

  @override
  State<TabledScroller> createState() => _TabledScrollerState();
}

class _TabledScrollerState extends State<TabledScroller> {
  static final Key _centerKey = UniqueKey();
  late final CalendarViewer _viewer;
  late final ScrollPhysics _physics;
  bool _snapping = false;

  CalendarController get _controller => _viewer.controller;
  DateTime get recorded => widget.metrics.indexer(_viewer.datetime, 0);
  DateTime get scrolled => _controller.datetime;

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
        _controller.datetime = recorded;
        _controller.jumpTo(notification.metrics.pixels - offset);
        widget.metrics.shift(index);
        setState(() {});
        _snapping = false;
        return false;
      }
    }
    return false;
  }

  void _animate(CalendarSwipe swipe) {
    if (!_controller.hasClients) return;
    final snap = widget.metrics.swipe(swipe);
    if (snap != 0) {
      _controller.animateTo(
        widget.metrics.offset(snap),
        duration: viewSwipeDelay,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    _viewer = context.read<CalendarViewer>();
    _physics = (_controller.scroll == CalendarScroll.snapping)
        ? SnapPhysics(metrics: widget.metrics)
        : ScrollPhysics();
    _controller.datetime = recorded;
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
        controller: _controller,
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
  final TabledMetrics metrics;

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
        spring, position.pixels, target, velocity,
        tolerance: toleranceFor(position),
      );
    }
    return null;
  }
}
