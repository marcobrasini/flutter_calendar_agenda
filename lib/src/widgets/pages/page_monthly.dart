import 'package:flutter/material.dart';
import '../frames/frame_monthly.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import 'page_slot.dart';


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

  @override
  Widget build(BuildContext context) {
    final start = month.weekStart.date;
    final slotPainter = Column(
      children: [
        for (int i = 0; i < weekScheme.count; i++)
          Row(
            children: [
              for (int j = 0; j < dateScheme.count; j++)
                SlotPage(
                  date: start + (i * WeekScheme.step + j) + (dateScheme.beg - 1),
                  width: width / dateScheme.count,
                  height: height / weekScheme.count,
                ),
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
            onTap: callbacks.onFrameTap,
            onDoubleTap: callbacks.onFrameDoubleTap,
            onLongPress: callbacks.onFrameLongPress,
          ),
          slotPainter,
        ],
      ),
    );
  }
}
