import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../modifier.dart';
import '../picker.dart';
import '../viewer.dart';
import '../config.dart';
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

class _CalendarTabledHeaderState extends State<CalendarTabledHeader> {
  late final CalendarPicker picker;
  TabledMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    picker = context.read<CalendarPicker>();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarPicker>();
    final modifier = context.watch<CalendarModifier>();
    final config = CalendarConfig.of(context);
    final headerConfig = config.headerConfig(picker.view);
    final headerColor = headerConfig.background;
    final headerStyle = headerConfig.textStyle;
    final metrics = _metrics ??= TabledMetrics(
      view: picker.view,
      timeScheme: null,
      dateScheme: widget.dateScheme,
      weekScheme: widget.weekScheme,
      direction: config.scrollDirection(picker.view),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final pickWidth = constraints.maxWidth;
        final pickHeight = 50.0 * (widget.weekScheme?.count ?? 1);
        metrics.resize(pickWidth, pickHeight);
        return Container(
          color: headerColor,
          child: Column(
            children: [
              Row(
                children: [
                  if (config.showHeaderButton) IconButton(
                    onPressed: (modifier.isResizing) ? null : () {
                      picker.swipe(CalendarSwipe.backward);
                    },
                    icon: Icon(Icons.arrow_left,
                      color: headerStyle?.color,
                      size: headerStyle?.fontSize,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: config.headerBuilder?.call(
                          context, picker.datetime.first, picker.datetime.last
                      ) ?? Text(
                        picker.title(context),
                        style: headerStyle,
                      ),
                    ),
                  ),
                  if (config.showHeaderButton) IconButton(
                    onPressed: (modifier.isResizing) ? null : () {
                      picker.swipe(CalendarSwipe.forward);
                    },
                    icon: Icon(Icons.arrow_right,
                      color: headerStyle?.color,
                      size: headerStyle?.fontSize,
                    ),
                  ),
                ],
              ),
              HeaderPicker(metrics: metrics)
            ],
          ),
        );
      }
    );
  }
}
