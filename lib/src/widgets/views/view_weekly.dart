import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/indicator_time.dart';
import '../tools/header_weekly.dart';
import '../tools/header_time.dart';
import '../pages/page_viewer.dart';
import '../pages/page_weekly.dart';
import '../slots/slot_modify.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../modifier.dart';
import '../../context.dart';
import '../../config.dart';


class WeeklyView extends StatefulWidget {

  const WeeklyView({
    super.key,
    required this.dateScheme,
    required this.timeScheme,
    required this.callbacks,
    //
    this.cornerWidget,
  });

  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  final CallbackScheme callbacks;
  final Widget? cornerWidget;

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  final _viewer = PageController(initialPage: 1);
  final _scroller = ScrollController();
  final _keyScroll = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      final renderer = _keyScroll.currentContext?.findRenderObject() as RenderBox;
      modifier.attachSlider(_scroller);
      modifier.attachRenderer(renderer);
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
                  child: WeeklyHeader(
                    width: pageWidth,
                    height: pageHeight,
                    scheme: widget.dateScheme,
                    controller: _viewer,
                  ),
                ),
              ]
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
                            builder: (date) => WeeklyPage(
                              week: date.toWeek,
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
                            length: (pageWidth - offset) / widget.dateScheme.count,
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
