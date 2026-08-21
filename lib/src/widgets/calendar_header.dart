import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modifier.dart';
import '../viewer.dart';
import '../config.dart';
import '../enums.dart';


class CalendarTabledHeader extends StatelessWidget {

  final bool showButtons;

  const CalendarTabledHeader({
    super.key,
    this.showButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewer = context.watch<CalendarViewer>();
    final modifier = context.watch<CalendarModifier>();
    final header = CalendarConfig.of(context).header;
    final colors = Theme.of(context).colorScheme;
    final color = header.background ?? colors.primary;
    final style = header.textStyle?.copyWith(color: colors.onPrimary)
        ?? TextStyle(color: colors.onPrimary);
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        color: color,
        child: Column(
          children: [
            Row(
              children: [
                if (showButtons) IconButton(
                  onPressed: (modifier.isResizing) ? null : () {
                    viewer.swipe(CalendarSwipe.backward);
                  },
                  icon: Icon(Icons.arrow_left,
                    color: style.color,
                    size: style.fontSize,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      viewer.title(context),
                      style: style,
                    ),
                  ),
                ),
                if (showButtons) IconButton(
                  onPressed: (modifier.isResizing) ? null : () {
                    viewer.swipe(CalendarSwipe.forward);
                  },
                  icon: Icon(Icons.arrow_right,
                    color: style.color,
                    size: style.fontSize,
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
