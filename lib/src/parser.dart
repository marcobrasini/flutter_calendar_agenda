import 'utils/datetime.dart';
import 'enums.dart';


mixin CalendarParser {

  CalendarView get view;
  late DateTime _datetime;

  dynamic get datetime => _datetime;
  set datetime(DateTime datetime) => _datetime = normalize(datetime);

  DateTime normalize(DateTime datetime) => switch (view) {
    CalendarView.daily   => datetime.date,
    CalendarView.weekly  => datetime.toWeek,
    CalendarView.monthly => datetime.toMonth,
  };

  Date  get asDate  => _datetime.date;
  Week  get asWeek  => _datetime.toWeek;
  Month get asMonth => _datetime.toMonth;

  Date get start => (_datetime as dynamic).start;
  Date get stop  => (_datetime as dynamic).stop;
}