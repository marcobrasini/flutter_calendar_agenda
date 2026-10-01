import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../picker.dart';
import 'tabled_scroller.dart';
import 'tabled_metrics.dart';
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
    return SizedBox(
      width: widget.metrics.width,
      height: widget.metrics.height,
      child: TabledScroller(
        viewer: _picker,
        metrics: widget.metrics,
        builder: (key, datetime) => HeaderSlot(
          key: key,
          date: datetime.date,
          width: widget.metrics.width,
          height: widget.metrics.height/(widget.metrics.weekScheme?.count ?? 1),
          dateScheme: widget.metrics.dateScheme!,
        ),
      ),
    );
  }
}
