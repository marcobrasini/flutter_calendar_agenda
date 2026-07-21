import 'package:calendar/src/timer.dart';
import 'package:calendar/src/widgets/pages/page_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modifier.dart';
import '../../viewer.dart';
import '../../config.dart';
import '../../const.dart';
import '../../enums.dart';


typedef PageBuilder = PageWidget Function(DateTime);


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
  final List<PageWidget> _pages = [];

  @override
  void initState() {
    super.initState();
    final viewer = context.read<CalendarViewer>();
    final modifier = context.read<CalendarModifier>();
    modifier.attachSwiper(viewer);
    _datetime = viewer.datetime;
    _pages.addAll([-1, 0, 1].map((i) => widget.builder(_datetime + i)));
    widget.controller.addListener(_swiping);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.jumpToPage(1);
    });
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
        if (index == 0) {
          controller.last();
          setState(() {
            _datetime = controller.datetime;
            _pages
              ..removeAt(2)
              ..insert(0, widget.builder(_datetime - 1));
          });
        }
        if (index == 2) {
          controller.next();
          setState(() {
            _datetime = controller.datetime;
            _pages
              ..removeAt(0)
              ..insert(2, widget.builder(_datetime + 1));
          });
        }
        widget.controller.jumpToPage(1);
        timer.swipe(0.0);
      });
    }
  }

  void _animate(CalendarSwipe swipe) {
    if (!widget.controller.hasClients) return;
    final page = ViewerPage.pages[swipe];
    if (page != null) {
      widget.controller.animateToPage(
        page,
        duration: viewSwipeDelay,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewer = context.watch<CalendarViewer>();
    if (viewer.swiping != null) {
      final swipe = viewer.swiping!;
      viewer.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animate(swipe);
      });
    }
    return PageView(
      scrollDirection: widget.direction,
      controller: widget.controller,
      children: _pages,
    );
  }
}
