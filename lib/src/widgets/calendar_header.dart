import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/schemes.dart';
import '../modifier.dart';
import '../context.dart';
import '../picker.dart';
import '../enums.dart';
import 'header_picker.dart';
import 'tabled_metrics.dart';


class CalendarTabledHeader extends StatefulWidget {
  const CalendarTabledHeader({
    required this.dateScheme,
    this.weekScheme,
    super.key,
  });

  final DateScheme dateScheme;
  final WeekScheme? weekScheme;

  @override
  State<CalendarTabledHeader> createState() => _CalendarTabledHeaderState();
}

class _CalendarTabledHeaderState extends State<CalendarTabledHeader>
    with SingleTickerProviderStateMixin {
  late final CalendarPicker _picker;
  late final AnimationController _expand;
  TabledMetrics? _metrics;

  bool get _isExpanded =>
      _expand.status == AnimationStatus.forward ||
      _expand.status == AnimationStatus.completed;

  void _toggle() => _isExpanded ? _expand.reverse() : _expand.forward();

  @override
  void initState() {
    super.initState();
    _picker = context.read<CalendarPicker>();
    _expand = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _expand.dispose();
    _metrics?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarPicker>();
    final modifier = context.watch<CalendarModifier>();
    final headerConfig = context.config.headerConfig(_picker.view);
    final headerColor = headerConfig.background;
    final headerStyle = headerConfig.textStyle;
    final metrics = _metrics ??= TabledMetrics(
      view: _picker.view,
      timeScheme: null,
      dateScheme: widget.dateScheme,
      weekScheme: widget.weekScheme,
      direction: context.config.scrollDirection(_picker.view),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final pickWidth = constraints.maxWidth;
        final slotHeight = context.dateOffset(_picker.view);
        final pageHeight = slotHeight * (widget.weekScheme?.count ?? 1);
        metrics.resize(pickWidth, pageHeight);
        return Container(
          color: headerColor,
          child: Column(
            children: [
              Row(
                children: [
                  if (context.config.showHeaderButton) IconButton(
                    onPressed: (modifier.isResizing) ? null : () {
                      _picker.swipe(CalendarSwipe.backward);
                    },
                    icon: Icon(Icons.arrow_left,
                      color: headerStyle?.color,
                      size: headerStyle?.fontSize,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: context.config.showHeaderPicker ? _toggle : null,
                      child: Center(
                        child: context.config.headerBuilder?.call(
                          context,
                          _picker.datetime.first,
                          _picker.datetime.last,
                        ) ?? Text(
                          _picker.title(context),
                          style: headerStyle,
                        ),
                      ),
                    ),
                  ),
                  if (context.config.showHeaderButton) IconButton(
                    onPressed: (modifier.isResizing) ? null : () {
                      _picker.swipe(CalendarSwipe.forward);
                    },
                    icon: Icon(Icons.arrow_right,
                      color: headerStyle?.color,
                      size: headerStyle?.fontSize,
                    ),
                  ),
                ],
              ),
              if (context.config.showHeaderPicker) SizeTransition(
                axisAlignment: -1.0,
                sizeFactor: CurvedAnimation(
                  curve: Curves.easeInOut,
                  parent: _expand,
                ),
                child: HeaderPicker(metrics: metrics),
              ),
            ],
          ),
        );
      }
    );
  }
}
