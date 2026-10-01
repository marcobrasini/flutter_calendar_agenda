import 'package:calendar/src/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools/indicator_time.dart';
import 'tools/header_time.dart';
import 'slots/slot_editor.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../modifier.dart';
import '../scroller.dart';
import '../context.dart';
import '../config.dart';
import '../viewer.dart';
import 'tabled_scroller.dart';
import 'tabled_metrics.dart';
import 'tabled_header.dart';
import 'tabled_slot.dart';


class CalendarTabled extends StatefulWidget {

  const CalendarTabled({
    super.key,
    required this.timeScheme,
    required this.dateScheme,
    required this.weekScheme,
    required this.callbacks,
    this.cornerWidget,
    this.slider,
  });

  final DateScheme dateScheme;
  final WeekScheme? weekScheme;
  final TimeScheme? timeScheme;
  final CallbackScheme callbacks;
  final WidgetBuilder? cornerWidget;
  final ScrollController? slider;

  @override
  State<CalendarTabled> createState() => _CalendarTabledState();
}

class _CalendarTabledState extends State<CalendarTabled> {
  final GlobalKey _viewport = GlobalKey();
  late final ScrollController _slider;
  late final CalendarViewer _viewer;
  TabledMetrics? _metrics;

  CalendarScroller get _scroller => _viewer.scroller;
  CalendarView get _view => _viewer.view;

  @override
  void initState() {
    super.initState();
    _viewer = context.read<CalendarViewer>();
    _slider = widget.slider ?? ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      final content = _scroller.key.currentContext?.findRenderObject();
      modifier.attachViewport(_viewport);
      modifier.attachContent(content as RenderBox?);
      modifier.attachSlider(_slider);
      modifier.reset();
    });
  }

  @override
  void dispose() {
    _metrics?.dispose();
    if (widget.slider == null) _slider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final slideDirection = config.slideDirection(_view);
    final showIndicator = config.showIndicator && (
        widget.timeScheme != null || widget.weekScheme != null
    );
    final metrics = _metrics ??= TabledMetrics(
      view: _view,
      timeScheme: widget.timeScheme,
      dateScheme: widget.dateScheme,
      weekScheme: widget.weekScheme,
      direction: config.scrollDirection(_view),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin();
        final timeOffset = context.timeOffset();
        final dateOffset = context.dateOffset(_view);
        final pageHeight = (
            widget.timeScheme == null || widget.timeScheme?.ratio == 0
        )   ? constraints.maxHeight - timeMargin - dateOffset
            : widget.timeScheme!.minutes * widget.timeScheme!.ratio;
        final pageWidth = constraints.maxWidth - (
            widget.timeScheme != null ? timeOffset : 0.0
        );
        final slotHeight = pageHeight / (widget.weekScheme?.count ?? 1);
        metrics.resize(pageWidth, pageHeight);
        return Column(
          children: [
            if (config.showHeaderWidget) Row(
              children: [
                if (widget.timeScheme != null) SizedBox(
                  width: timeOffset,
                  height: dateOffset,
                  child: widget.cornerWidget?.call(context),
                ),
                SizedBox(
                  width: pageWidth,
                  height: dateOffset,
                  child: TabledHeader(
                    metrics: metrics,
                    scroller: (widget.weekScheme == null) ? _scroller : null,
                    config: (widget.weekScheme == null)
                        ? config.dateConfig(_viewer.view)
                        : config.weekConfig(_viewer.view),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                key: _viewport,
                scrollDirection: slideDirection,
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
                          TabledScroller(
                            key: _scroller.key,
                            viewer: _viewer,
                            metrics: metrics,
                            builder: (key, datetime) => TabledSlot(
                              key: key,
                              date: datetime.date,
                              width: pageWidth,
                              height: slotHeight,
                              timeScheme: widget.timeScheme,
                              dateScheme: widget.dateScheme,
                              callbacks: widget.callbacks,
                            ),
                          ),
                          if (showIndicator) TimeIndicator(
                            metrics: metrics,
                            scroller: _scroller,
                            direction: metrics.direction,
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
