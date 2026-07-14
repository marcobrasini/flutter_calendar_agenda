import 'package:flutter/material.dart';
import '../frames/frame_monthly.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';


class MonthlyPage extends StatelessWidget {

  const MonthlyPage({
    super.key,
    required this.month,
    required this.width,
    required this.height,
    required this.dateScheme,
    required this.weekScheme,
    required this.callbacks,
  });

  final Month month;
  final double width;
  final double height;
  final DateScheme dateScheme;
  final WeekScheme weekScheme;
  final CallbackScheme callbacks;
  double get dateScale => dateScheme.scale(width);
  double get weekScale => weekScheme.scale(height);

  DateTime _date(Offset local) {
    final weeks = (local.dy * weekScale).toInt();
    final days = (local.dx * dateScale).toInt();
    final date = month.weekStart.date;
    return date + weeks * 7 + days;
  }

  @override
  Widget build(BuildContext context) {
    final start = month.weekStart.date;
    final slotPainter = Column(
      children: [
        for (int i = 0; i < weekScheme.count; i++)
          Row(
            children: [
              // for (int j = 0; j < dateScheme.count; j++)
              //   SlotPage(
              //     date: start + (i * WeekScheme.step + j) + (dateScheme.beg - 1),
              //     width: width / dateScheme.count,
              //     height: height / weekScheme.count,
              //   ),
            ],
          )
      ],
    );
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          MonthlyFrame(
            width: width,
            height: height,
            weekScheme: weekScheme,
            dateScheme: dateScheme,
            onTap: (local, [_]) => callbacks.onFrameTap?.call(_date(local)),
            onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(_date(local)),
            onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(_date(local)),
          ),
          slotPainter,
        ],
      ),
    );
  }
}
