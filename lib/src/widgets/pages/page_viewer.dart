import 'package:calendar/src/timer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modifier.dart';
import '../../viewer.dart';
import '../../config.dart';
import '../../const.dart';
import '../../enums.dart';


typedef PageBuilder = Widget Function(DateTime date);


class ViewerPage extends StatefulWidget {
  static const pages = {
    CalendarSwipe.backward: 0,
    CalendarSwipe.forward: 2,
  };

  const ViewerPage({
    super.key,
    required this.controller,
    required this.builder,
    required this.direction,
  });

  final PageController controller;
  final PageBuilder builder;
  final Axis direction;

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}


class _ViewerPageState extends State<ViewerPage> {
  dynamic _datetime;

  @override
  void initState() {
    widget.controller.addListener(_swiping);
    final viewer = context.read<CalendarViewer>();
    final modifier = context.read<CalendarModifier>();
    modifier.attachSwiper(viewer);
    _datetime = viewer.datetime;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_swiping);
    widget.controller.dispose();
    super.dispose();
  }

  void _swiping() {
    if (!widget.controller.hasClients) return;
    final timer = context.read<CalendarTimer>();
    final page = widget.controller.page!;
    timer.swipe(page - 1.0);
    if ((page == 0.0 || page == 2.0)) {
      final index = page.round();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = context.read<CalendarViewer>();
        if (index == 0) controller.last();
        if (index == 2) controller.next();
        setState(() {
          _datetime = controller.datetime;
        });
        widget.controller.jumpToPage(1);
        timer.swipe(0.0);
      });
    }
  }

  void _onAnimate(CalendarViewer viewer) {
    if (!widget.controller.hasClients) return;
    final page = ViewerPage.pages[viewer.swiping!];
    if (page != null) {
      if (!mounted) return;
      widget.controller.animateToPage(
        page,
        duration: viewSwipeDelay,
        curve: Curves.easeInOut,
      ).then((_) {
        setState(() {
          _datetime = viewer.datetime;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.controller.jumpToPage(1);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final viewer = context.watch<CalendarViewer>();
    if (viewer.swiping != null) {
      _onAnimate(viewer);
      viewer.clear();
    }
    return PageView.builder(
      scrollDirection: config.view.swipeDirection,
      controller: widget.controller,
      itemCount: 3,
      itemBuilder: (context, index) => widget.builder(_datetime + index-1),
    );
  }
}
