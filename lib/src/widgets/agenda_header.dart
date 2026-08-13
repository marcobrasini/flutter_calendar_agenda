import 'package:flutter/material.dart';
import '../config.dart';
import '../const.dart';


class AgendaHeader extends StatelessWidget {

  final dynamic datetime;
  final VoidCallback? onTap;

  const AgendaHeader({
    super.key,
    required this.datetime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    return Builder(
      builder: (context) {
        return Row(
          children: [
            if (config.view.showHeaderButton) IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_left),
            ),
            Expanded(
              child: GestureDetector(
              onTap: config.view.showHeaderButton ? onTap : null,
                child: config.header.builder?.call(
                    context, datetime.first, datetime.last
                ) ?? Container(
                  color: config.header.background,
                  padding: EdgeInsetsGeometry.all(config.header.padding),
                  child: Text(
                    datetime.format(config.header.format ?? defaultDateFormat),
                    style: config.header.textStyle,
                  ),
                ),
              ),
            ),
            if (config.view.showHeaderButton) IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_right),
            ),
          ],
        );
      },
    );
  }
}
