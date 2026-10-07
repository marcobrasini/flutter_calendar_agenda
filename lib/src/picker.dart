import 'viewer.dart';
import 'enums.dart';


class CalendarPicker extends CalendarViewer {
  CalendarPicker({
    required super.view,
    required super.scroll,
  });

  CalendarViewer? _viewer;
  CalendarViewer? get viewer => _viewer;
  bool get negligible => view == _viewer?.view;
  bool _stepping = false;   // picker-activated flag: calling for super-methods
  bool _leading = false;    // activating-viewer flag: no sync callback

  void attachViewer(CalendarViewer? viewer) {
    if (identical(viewer, _viewer)) return;
    _viewer?.removeListener(sync);
    _viewer = viewer?..addListener(sync);
  }

  void sync() {
    if (_leading) return;
    final target = _viewer?.datetime;
    if (target == null) return;
    if (normalize(target) != datetime) {
      jump(target);
    } else if (!negligible) {
      notifyListeners();
    }
  }

  void _lead(void Function(CalendarViewer viewer) step) {
    final viewer = _viewer;
    if (viewer == null || !negligible) return;
    _leading = true;
    try {
      step(viewer);
    } finally {
      _leading = false;
    }
  }

  void pick(DateTime datetime) => (_viewer ?? this).jump(datetime);

  @override
  void next([bool swiping = false]) {
    _stepping = true;
    try {
      super.next(swiping);
      _lead((viewer) => viewer.next(swiping));
    } finally {
      _stepping = false;
    }
  }

  @override
  void last([bool swiping = false]) {
    _stepping = true;
    try {
      super.last(swiping);
      _lead((viewer) => viewer.last(swiping));
    } finally {
      _stepping = false;
    }
  }

  @override
  void swipe(CalendarSwipe swipe) {
    if (_stepping) return super.swipe(swipe);
    final target = _viewer ?? this;
    switch (swipe) {
      case CalendarSwipe.forward:  target.next(true);
      case CalendarSwipe.backward: target.last(true);
    }
  }

  @override
  void dispose() {
    _viewer?.removeListener(sync);
    super.dispose();
  }
}