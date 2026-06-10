import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller.dart';


typedef PageBuilder = Widget Function(DateTime date);


class ViewerPage extends StatefulWidget {

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
      _settling = true;
      final index = page.round();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final controller = context.read<CalendarController>();
        if (index == 0) controller.last();
        if (index == 2) controller.next();
        _pageController.jumpToPage(1);
        _settling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _datetime = context.watch<CalendarController>().datetime;
    return PageView.builder(
      scrollDirection: widget.direction,
      controller: _pageController,
      itemCount: 3,
      itemBuilder: (context, index) => widget.builder(_datetime + index - 1),
    );
  }
}
