import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools/indicator_time.dart';
import '../utils/datetime.dart';
import '../picker.dart';
import '../context.dart';
import 'tabled_scroller.dart';
import 'tabled_metrics.dart';
import 'tabled_header.dart';
import 'header_slot.dart';


class HeaderPicker extends StatefulWidget {
  const HeaderPicker({
    required this.metrics,
    super.key
  });

  final TabledMetrics metrics;

  @override
  State<HeaderPicker> createState() => _HeaderPickerState();
}

class _HeaderPickerState extends State<HeaderPicker> {
  late final CalendarPicker _picker;

  @override
  void initState() {
    super.initState();
    _picker = context.read<CalendarPicker>();
  }

  @override
  Widget build(BuildContext context) {
    final slotCount = widget.metrics.weekScheme?.count ?? 1;
    return Column(
      children: [
        if (widget.metrics.weekScheme != null) TabledHeader(
          width: widget.metrics.width,
          height: widget.metrics.height,
          metrics: widget.metrics
        ),
        SizedBox(
          width: widget.metrics.width,
          height: widget.metrics.height,
          child: Stack(
            children: [
              TabledScroller(
                viewer: _picker,
                metrics: widget.metrics,
                builder: (key, datetime) => HeaderSlot(
                  key: key,
                  date: datetime.date,
                  width: widget.metrics.width,
                  height: widget.metrics.height/slotCount,
                  dateScheme: widget.metrics.dateScheme!,
                ),
              ),
              if (context.config.showIndicator) TimeIndicator(
                metrics: widget.metrics,
                scroller: _picker.scroller,
                direction: widget.metrics.direction,
              )
            ],
          )
        ),
      ],
    );
  }
}
