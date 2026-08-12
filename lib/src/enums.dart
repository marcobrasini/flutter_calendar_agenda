// ── Calendar enums ────────────────────────────────────────────────────────
enum CalendarView {
  daily,
  weekly,
  monthly,
}

enum CalendarSwipe {
  forward,
  backward,
}

enum CalendarScroll {
  continuous,
  sequential,
  snapping,
}

// ── Other enums ───────────────────────────────────────────────────────────
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

enum SlotAction {
  none,
  dragging,
  resizing,
}

enum ResizeSide {
  before,
  after,
  none,
}

enum GestureType {
  tap,
  doubleTap,
  longPress,
}

enum TimeStep {
  minutes60(60),
  minutes30(30),
  minutes15(15),
  hours24(1440);

  final int minutes;
  const TimeStep(this.minutes);
}