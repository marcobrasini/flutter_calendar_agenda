import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modifier.dart';
import '../viewer.dart';
import '../config.dart';
import '../enums.dart';


class CalendarTabledHeader extends StatelessWidget {

  const CalendarTabledHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final viewer = context.watch<CalendarViewer>();
    final modifier = context.watch<CalendarModifier>();
    final config = CalendarConfig.of(context);
    final header = CalendarConfig.of(context).header;
    final color = header.background;
    final style = header.textStyle;
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        color: color,
        child: Column(
          children: [
            Row(
              children: [
                if (config.showHeaderButton) IconButton(
                  onPressed: (modifier.isResizing) ? null : () {
                    viewer.swipe(CalendarSwipe.backward);
                  },
                  icon: Icon(Icons.arrow_left,
                    color: style?.color,
                    size: style?.fontSize,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: config.headerBuilder?.call(
                        context, viewer.datetime.first, viewer.datetime.last
                    ) ?? Text(
                      viewer.title(context),
                      style: style,
                    ),
                  ),
                ),
                if (config.showHeaderButton) IconButton(
                  onPressed: (modifier.isResizing) ? null : () {
                    viewer.swipe(CalendarSwipe.forward);
                  },
                  icon: Icon(Icons.arrow_right,
                    color: style?.color,
                    size: style?.fontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
