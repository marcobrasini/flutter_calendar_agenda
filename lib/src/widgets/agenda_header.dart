import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/schemes.dart';
import '../viewer.dart';
import '../config.dart';
import '../const.dart';
import '../enums.dart';


class AgendaHeader extends StatelessWidget {

  final dynamic datetime;
  final DateScheme? dateScheme;
  final VoidCallback? onTap;

  const AgendaHeader({
    super.key,
    required this.datetime,
    this.dateScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final viewer = context.read<CalendarViewer>();
    final headerConfig = config.headerConfig(viewer.view);
    return Row(
      children: [
        if (config.showHeaderButton) IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () {
            viewer.datetime = datetime;
            viewer.swipe(CalendarSwipe.backward);
          },
        ),
        Expanded(
          child: GestureDetector(
          onTap: config.showHeaderButton ? onTap : null,
            child: config.headerBuilder?.call(
                context,
                datetime.first + (dateScheme?.beg ?? 0),
                datetime.last + (dateScheme?.beg ?? 0),
            ) ?? Container(
              color: headerConfig.background,
              padding: EdgeInsetsGeometry.all(headerConfig.textPadding),
              child: Text(
                datetime.format(headerConfig.format ?? defaultDateFormat),
                style: headerConfig.textStyle,
              ),
            ),
          ),
        ),
        if (config.showHeaderButton) IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () {
            viewer.datetime = datetime;
            viewer.swipe(CalendarSwipe.forward);
          },
        ),
      ],
    );
  }
}
