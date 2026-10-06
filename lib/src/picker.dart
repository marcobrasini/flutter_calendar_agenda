import 'viewer.dart';
import 'enums.dart';


class CalendarPicker extends CalendarViewer {
  CalendarPicker({
    required super.view,
    required super.scroll,
  });

  CalendarViewer? viewer;
  bool _stepping = false;

  void attachViewer(CalendarViewer viewer) {
    this.viewer?.removeListener(sync);
    this.viewer = viewer..addListener(sync);
  }

  void sync() {
    final target = viewer?.datetime;
    if (target == null) return;
    if (normalize(target) == datetime) {
      notifyListeners();
    } else {
      jump(target);
    }
  }

  void pick(DateTime datetime) {
    (viewer != null) ? viewer!.jump(datetime) : jump(datetime);
  }

  @override
  void next([bool swiping = false]) {
    _stepping = true;
    try {
      super.next(swiping);
    } finally {
      _stepping = false;
    }
  }

  @override
  void last([bool swiping = false]) {
    _stepping = true;
    try {
      super.last(swiping);
    } finally {
      _stepping = false;
    }
  }

  @override
  void swipe(CalendarSwipe swipe, [bool header = false]) {
    if (_stepping) return super.swipe(swipe);
    final target = viewer ?? this;
    switch(swipe) {
      case CalendarSwipe.forward:   target.next(true);
      case CalendarSwipe.backward:  target.last(true);
    }
  }

  @override
  void dispose() {
    viewer?.removeListener(sync);
    super.dispose();
  }
}