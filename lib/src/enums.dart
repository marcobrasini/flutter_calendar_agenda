enum CalendarView {
  daily,
  weekly,
  monthly,
}

enum CalendarSwipe {
  forward,
  backward,
}

enum LineStyle {
  solid,
  dashed,
}

enum LineDirection {
  horizontal,
  vertical,
}

enum SlotDirection {
  horizontal,
  vertical,
}

enum TimeStep {
  minutes60(60),
  minutes30(30),
  minutes15(15);

  final int minutes;
  const TimeStep(this.minutes);
}