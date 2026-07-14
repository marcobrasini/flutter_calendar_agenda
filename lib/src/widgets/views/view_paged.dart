import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/indicator_time.dart';
import '../tools/header_time.dart';
import '../pages/page_viewer.dart';
import '../pages/page_header.dart';
import '../pages/page_widget.dart';
import '../slots/slot_modify.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../modifier.dart';
import '../../context.dart';
import '../../config.dart';


class CalendarPageView extends StatefulWidget {
  const CalendarPageView({
    super.key,
    required this.timeScheme,
    required this.dateScheme,
    required this.callbacks,
    //
    this.cornerWidget,
  });

  final TimeScheme timeScheme;
  final DateScheme dateScheme;
  final CallbackScheme callbacks;
  final Widget? cornerWidget;

  @override
  State<CalendarPageView> createState() => _CalendarPageViewState();
}

class _CalendarPageViewState extends State<CalendarPageView> {
  final _viewer = PageController(initialPage: 1);
  final _scroller = ScrollController();
  final _keyScroll = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      final renderer = _keyScroll.currentContext?.findRenderObject();
      modifier.attachRenderer(renderer as RenderBox);
      modifier.attachSlider(_scroller);
      modifier.reset();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final offset = config.view.indicatorRadius;
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin();
        final timeOffset = context.timeOffset();
        final dateOffset = context.dateOffset();
        //
        final pageHeight = (widget.timeScheme.ratio == 0)
            ? constraints.maxHeight - timeMargin - dateOffset
            : widget.timeScheme.minutes * widget.timeScheme.ratio;
        final pageWidth = constraints.maxWidth - timeOffset;
        // final space = (pageWidth - offset) / widget.dateScheme.count;
        //
        return Column(
          children: [
            if (config.view.showHeader) Row(
              children: [
                SizedBox(
                  width: timeOffset,
                  height: dateOffset,
                  child: widget.cornerWidget,
                ),
                SizedBox(
                  width: pageWidth,
                  height: dateOffset,
                  child: PageHeader(
                    width: pageWidth,
                    height: pageHeight,
                    scheme: widget.dateScheme,
                    controller: _viewer,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView (
                key: _keyScroll,
                controller: _scroller,
                child: Row (
                  children: [
                    TimeHeader(
                      width: timeOffset,
                      height: pageHeight,
                      scheme: widget.timeScheme,
                    ),
                    SizedBox(
                      width: pageWidth,
                      height: pageHeight,
                      child: Stack(
                        children: [
                          ViewerPage(
                            controller: _viewer,
                            direction: config.view.swipeDirection,
                            builder: (datetime) => PageWidget(
                              date: datetime.date,
                              width: pageWidth,
                              height: pageHeight,
                              timeScheme: widget.timeScheme,
                              dateScheme: widget.dateScheme,
                              callbacks: widget.callbacks,
                            ),
                          ),
                          TimeIndicator(
                            width: pageWidth,
                            height: pageHeight,
                            timeScheme: widget.timeScheme,
                            dateScheme: widget.dateScheme,
                          ),
                          Builder(
                            builder: (context) {
                              final modifier = context.watch<CalendarModifier>();
                              return SizedBox(
                                width: pageWidth,
                                height: pageHeight,
                                child: (modifier.editing)
                                    ? EditSlot(layout: modifier.layout!)
                                    : SizedBox.shrink(),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
