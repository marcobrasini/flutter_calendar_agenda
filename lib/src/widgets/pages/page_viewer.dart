import 'package:calendar/src/config.dart';
import 'package:calendar/src/const.dart';
import 'package:calendar/src/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller.dart';


typedef PageBuilder = Widget Function(DateTime date);


class ViewerPage extends StatefulWidget {
  static const pages = {
    CalendarSwipe.backward: 0,
    CalendarSwipe.forward: 2,
  };

  const ViewerPage({
    super.key,
    required this.builder,
    required this.direction,
  });

  final PageBuilder builder;
  final Axis direction;

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}


class _ViewerPageState extends State<ViewerPage> {
  late final PageController _pageController;
  dynamic _datetime;
  bool _settling = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1,
      keepPage: false,
    )..addListener(_onScroll);
    _datetime = context.read<CalendarController>().datetime;
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_pageController.hasClients || _settling) return;
    final page = _pageController.page!;
    if (page == 0.0 || page == 2.0) {
      final index = page.round();
      _settling = true;
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = context.read<CalendarController>();
        if (index == 0) controller.last(false);
        if (index == 2) controller.next(false);
        setState(() {
          _datetime = controller.datetime;
        });
        _pageController.jumpToPage(1);
        _settling = false;
      });
    }
  }

  void _onAnimate(CalendarSwipe swipe) {
    if (_settling || !_pageController.hasClients) return;
    final page = ViewerPage.pages[swipe];
    if (page != null) {
      _settling = true;
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(
          page,
          duration: swipeDuration,
          curve: Curves.easeInOut,
        ).then((_) {
          if (!mounted) return;
          final controller = context.read<CalendarController>();
          setState(() {
            _datetime = controller.datetime;
          });
          _pageController.jumpToPage(1);
          _settling = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final controller = context.watch<CalendarController>();
    if (controller.swipe != null) {
      _onAnimate(controller.swipe!);
      controller.clear();
    }
    // NON sincronizzare _datetime qui — viene aggiornato solo
    // dopo il completamento dell'animazione (vedi _onAnimate/_onScroll)
    return PageView.builder(
      scrollDirection: config.view.swipeDirection,
      controller: _pageController,
      itemCount: 3,
      itemBuilder: (context, index) => widget.builder(_datetime + index-1),
    );
  }
}