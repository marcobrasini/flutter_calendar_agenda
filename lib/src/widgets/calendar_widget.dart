import 'package:calendar/src/viewer.dart';
import 'package:calendar/src/widgets/calendar_scroller.dart';
import 'package:calendar/src/widgets/widget_slot.dart';
import 'package:calendar/src/widgets/slots/slot_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools/indicator_time.dart';
import 'tools/header_time.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../modifier.dart';
import '../context.dart';
import '../config.dart';
import '../metrics.dart';
import 'widget_header.dart';


class CalendarWidget extends StatefulWidget {

  const CalendarWidget({
    super.key,
    required this.timeScheme,
    required this.dateScheme,
    required this.weekScheme,
    required this.callbacks,
    //
    this.cornerWidget,
  });

  final DateScheme dateScheme;
  final WeekScheme? weekScheme;
  final TimeScheme? timeScheme;
  final CallbackScheme callbacks;
  final Widget? cornerWidget;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late final CalendarController _controller;
  late final ScrollController _slider;
  CalendarMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _slider = ScrollController();
    _controller =  context.read<CalendarViewer>().controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      final renderer = _controller.key.currentContext?.findRenderObject();
      modifier.attachRenderer(renderer as RenderBox);
      modifier.attachSlider(_slider);
      modifier.reset();
    });
  }

  @override
  void dispose() {
    _metrics?.dispose();
    _slider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final viewer = context.read<CalendarViewer>();
    final modifier = context.read<CalendarModifier>();
    final metrics = _metrics ??= CalendarMetrics(
      view: viewer.view,
      timeScheme: widget.timeScheme,
      dateScheme: widget.dateScheme,
      weekScheme: widget.weekScheme,
      direction: config.view.scrollDirection(viewer.view),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin();
        final timeOffset = context.timeOffset();
        final dateOffset = context.dateOffset();
        final pageHeight = (widget.timeScheme?.ratio == 0 || widget.timeScheme == null)
            ? constraints.maxHeight - timeMargin - dateOffset
            : widget.timeScheme!.minutes * widget.timeScheme!.ratio;
        final pageWidth = constraints.maxWidth - (widget.timeScheme != null ? timeOffset : 0.0);
        final slotHeight = pageHeight / (widget.weekScheme?.count ?? 1);
        metrics.resize(pageWidth, pageHeight);
        modifier.attachConverter(metrics.converter);
        return Column(
          children: [
            if (config.view.showHeader) Row(
              children: [
                if (widget.timeScheme != null) SizedBox(
                  width: timeOffset,
                  height: dateOffset,
                  child: widget.cornerWidget,
                ),
                SizedBox(
                  width: pageWidth,
                  height: dateOffset,
                  child: ViewHeader(
                    metrics: metrics,
                    controller: (widget.weekScheme == null) ? _controller : null,
                    config: (widget.weekScheme == null) ? config.date! : config.week!,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: config.view.slideDirection(viewer.view),
                controller: _slider,
                physics: (widget.timeScheme == null)
                    ? NeverScrollableScrollPhysics()
                    : null,
                child: Row (
                  children: [
                    if (widget.timeScheme != null) TimeHeader(
                      width: timeOffset,
                      height: pageHeight,
                      scheme: widget.timeScheme!,
                    ),
                    SizedBox(
                      width: pageWidth,
                      height: pageHeight,
                      child: Stack(
                        children: [
                          CalendarScroller(
                            key: _controller.key,
                            controller: _controller,
                            direction: config.view.scrollDirection(viewer.view),
                            metrics: metrics,
                            builder: (key, datetime) => WidgetSlot(
                              key: key,
                              date: datetime.date,
                              width: pageWidth,
                              height: slotHeight,
                              timeScheme: widget.timeScheme,
                              dateScheme: widget.dateScheme,
                              converter: metrics.converter,
                              callbacks: widget.callbacks,
                            ),
                          ),
                          if (widget.timeScheme != null || widget.weekScheme != null) TimeIndicator(
                            metrics: metrics,
                            controller: _controller,
                            direction: config.view.scrollDirection(viewer.view),
                          ),
                          Builder(
                            builder: (context) {
                              final modifier = context.watch<CalendarModifier>();
                              return SizedBox(
                                width: pageWidth,
                                height: pageHeight,
                                child: (modifier.editing)
                                    ? SlotEditor(
                                      layout: modifier.layout!,
                                    )
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
