import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import '../source.dart';
import '../enums.dart';
import 'tabled_scroller.dart';
import 'tabled_metrics.dart';
import 'tabled_header.dart';
import 'tabled_allday.dart';
import 'tabled_slider.dart';
import 'tabled_slot.dart';


class CalendarTabled extends StatefulWidget {

  const CalendarTabled({
    super.key,
    required this.timeScheme,
    required this.dateScheme,
    required this.weekScheme,
    this.cornerWidget,
    this.slider,
  });

  final DateScheme dateScheme;
  final WeekScheme? weekScheme;
  final TimeScheme? timeScheme;
  final WidgetBuilder? cornerWidget;
  final ScrollController? slider;

  @override
  State<CalendarTabled> createState() => _CalendarTabledState();
}

class _CalendarTabledState extends State<CalendarTabled> with TickerProviderStateMixin {
  final GlobalKey _viewport = GlobalKey();
  final ValueNotifier<Date?> _paged = ValueNotifier(null);
  late final ScrollController _slider;
  late final CalendarViewer _viewer;
  TabledMetrics? _metrics;

  CalendarScroller get _scroller => _viewer.scroller;
  CalendarView get _view => _viewer.view;

  void _syncPage() {
    if (!mounted || !_scroller.hasClients) return;
    if (_scroller.offset != 0.0) return;
    final date = _scroller.datetime.date;
    if (_paged.value != date) _paged.value = date;
  }

  void _viewerChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPage());
  }

  @override
  void initState() {
    super.initState();
    _viewer = context.read<CalendarViewer>();
    _slider = widget.slider ?? ScrollController();
    _scroller.addListener(_syncPage);
    _viewer.addListener(_viewerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      final content = _scroller.key.currentContext?.findRenderObject();
      modifier.attachViewport(_viewport);
      modifier.attachContent(content as RenderBox?);
      modifier.attachSlider(_slider);
      modifier.reset();
      _syncPage();
    });
  }

  @override
  void dispose() {
    _scroller.removeListener(_syncPage);
    _viewer.removeListener(_viewerChanged);
    _paged.dispose();
    _metrics?.dispose();
    if (widget.slider == null) _slider.dispose();
    super.dispose();
  }

  Widget _buildHeader(
      TabledMetrics metrics, 
      double timeOffset,
      double dateOffset, 
      double pageWidth
  ) {
    return Row(
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
            width: pageWidth,
            height: dateOffset,
            metrics: metrics,
            scroller: (widget.weekScheme == null) ? _scroller : null,
          ),
        ),
      ],
    );
  }

  int _rows(CalendarEvents source, TabledMetrics metrics, Date? page) {
    final start = (page ?? Week.weekDays.mon) + metrics.dateBeg;
    int rows = 0;
    for (int i = 0; i < metrics.dateCount; i++) {
      final n = source.forDate(start + i).where((e) => e.isAllDay).length;
      if (n > rows) rows = n;
    }
    return rows;
  }

  double _allDayExtent(
      CalendarEvents source,
      TabledMetrics metrics,
      Date? page,
      double tileHeight
    ) {
    if (widget.timeScheme == null) return 0.0;
    final date = (widget.weekScheme != null)
        ? null
        : page ?? metrics.indexer(_viewer.datetime, 0).date;
    return _rows(source, metrics, date) * tileHeight;
  }
  
  Widget _buildAllDay(
      TabledMetrics metrics,
      double timeOffset,
      double pageWidth,
  ) {
    return Row(
      children: [
        if (widget.timeScheme != null) SizedBox(
          width: timeOffset,
          child: Center(
            child: FittedBox(
              child: Text("All day",
                style: context.config.timeConfig().textStyle,
              ),
            ),
          ),
        ),
        SizedBox(
          width: pageWidth,
          child: TabledAllDay(
            metrics: metrics,
            scroller: (widget.weekScheme == null) ? _scroller : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    TabledMetrics metrics,
    double timeOffset,
    double pageWidth,
    double pageHeight,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.timeScheme != null) TimeHeader(
          width: timeOffset,
          height: pageHeight,
          scheme: widget.timeScheme!,
        ),
        SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: CompositedTransformTarget(
            link: _link,
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
                    height: pageHeight,
                    timeScheme: widget.timeScheme,
                    dateScheme: widget.dateScheme,
                  ),
                ),
                if (context.config.showIndicator) TimeIndicator(
                  metrics: metrics,
                  scroller: _scroller,
                  direction: metrics.direction,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  final LayerLink _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final metrics = _metrics ??= TabledMetrics(
      view: _view,
      timeScheme: widget.timeScheme,
      dateScheme: widget.dateScheme,
      weekScheme: widget.weekScheme,
      direction: config.scrollDirection(_view),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileHeight = context.tileHeight();
        final timeMargin = context.timeMargin() * 2;
        final timeOffset = context.timeOffset();
        final dateOffset = context.dateOffset(_view);
        final pageHeight = (widget.timeScheme == null ||
            widget.timeScheme?.ratio == 0)
            ? constraints.maxHeight - timeMargin - dateOffset
            : widget.timeScheme!.minutes * widget.timeScheme!.ratio;
        final pageWidth = constraints.maxWidth -
            (widget.timeScheme != null ? timeOffset : 0.0);
        metrics.resize(pageWidth, pageHeight);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            CustomScrollView(
              key: _viewport,
              controller: _slider,
              scrollDirection: config.slideDirection(_view),
              slivers: [
                if (config.showHeaderWidget) Builder(
                  builder: (context) {
                    final source = context.watch<CalendarEvents>();
                    return ValueListenableBuilder<Date?>(
                      valueListenable: _paged,
                      builder: (context, page, _) {
                        final target = _allDayExtent(source, metrics, page, tileHeight);
                        return TweenAnimationBuilder<double>(
                          tween: Tween(end: target),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          builder: (context, extent, _) => SliverKeepOffset(
                            sliver: SliverPersistentHeader(
                              pinned: true,
                              floating: true,
                              delegate: _TabledHeaderDelegate(
                                vsync: this,
                                headerExtent: dateOffset,
                                snapExtent: extent,
                                color: Theme.of(context).colorScheme.surface,
                                header: _buildHeader(metrics, timeOffset, dateOffset, pageWidth),
                                snap: _buildAllDay(metrics, timeOffset, pageWidth),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: _buildBody(metrics, timeOffset, pageWidth, pageHeight),
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final modifier = context.watch<CalendarModifier>();
                if (!modifier.editing) return const SizedBox.shrink();
                return Positioned.fill(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: modifier.end,
                        ),
                      ),
                      Positioned.fill(
                        child: ClipRect(
                          child: Stack(
                            children: [
                              CompositedTransformFollower(
                                link: _link,
                                showWhenUnlinked: false,
                                child: SizedBox(
                                  width: pageWidth,
                                  height: pageHeight,
                                  child: SlotEditor(layout: modifier.layout!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}


class _TabledHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabledHeaderDelegate({
    required this.vsync,
    required this.headerExtent,
    required this.snapExtent,
    required this.header,
    required this.snap,
    required this.color,
  });

  @override
  final TickerProvider vsync;
  final double headerExtent;
  final double snapExtent;
  final Widget header;
  final Widget snap;
  final Color color;

  @override
  double get minExtent => headerExtent;

  @override
  double get maxExtent => headerExtent + snapExtent;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration(
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
      );

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final visible = (snapExtent - shrinkOffset).clamp(0.0, snapExtent);
    return ColoredBox(
      color: color,
      child: Column(
        children: [
          SizedBox(height: headerExtent, child: header),
          SizedBox(
            height: visible,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minHeight: snapExtent,
                maxHeight: snapExtent,
                child: snap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabledHeaderDelegate old) =>
      old.headerExtent != headerExtent ||
          old.snapExtent != snapExtent ||
          old.header != header ||
          old.snap != snap ||
          old.color != color;
}
