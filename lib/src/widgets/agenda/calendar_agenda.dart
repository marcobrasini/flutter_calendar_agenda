import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CalendarAgenda extends StatefulWidget {
  const CalendarAgenda({super.key});

  @override
  State<CalendarAgenda> createState() => _CalendarAgendaState();
}

class _CalendarAgendaState extends State<CalendarAgenda> {
  late final CalendarController _controller;
  late final ScrollController _slider;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Placeholder();
      },
    );
  }
}
