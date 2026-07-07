import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/indicator_time.dart';
import '../tools/header_daily.dart';
import '../tools/header_time.dart';
import '../pages/page_viewer.dart';
import '../pages/page_daily.dart';
import '../slots/slot_modify.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../modifier.dart';
import '../../context.dart';
import '../../config.dart';


class DailyView extends StatefulWidget {
  const DailyView({
    super.key,
    required this.timeScheme,
    required this.callbacks,
    //
    this.cornerWidget,
  });

  final TimeScheme timeScheme;
  final CallbackScheme callbacks;
  final Widget? cornerWidget;

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
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
    final modifier = context.watch<CalendarModifier>();
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
                DailyHeader(
                  width: pageWidth,
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
                            builder: (date) => DailyPage(
                              date: date.date,
                              width: pageWidth,
                              height: pageHeight,
                              timeScheme: widget.timeScheme,
                              callbacks: widget.callbacks,
                            ),
                          ),
                          TimeIndicator(
                            width: pageWidth,
                            height: pageHeight,
                            timeScheme: widget.timeScheme,
                            length: pageWidth - offset,
                          ),
                          SizedBox(
                            width: pageWidth,
                            height: pageHeight,
                            child: (modifier.editing)
                                ? EditableSlot(layout: modifier.layout!)
                                : SizedBox.shrink(),
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
