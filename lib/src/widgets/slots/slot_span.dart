import '../../utils/datetime.dart';
import '../../data/event.dart';

class SlotSpan {
  SlotSpan(this.event, this.date);

  final Event event;
  final Date date;
  int lane = 0;

  int get beg => event.first % date;
  int get end => event.last % date;
  int get length => end - beg + 1;
}