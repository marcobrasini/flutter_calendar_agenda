import 'viewer.dart';


class CalendarPicker extends CalendarViewer {
  CalendarPicker({
    required super.view,
    required super.scroll,
  });

  CalendarViewer? viewer;
  void attachViewer(CalendarViewer viewer) =>
      this.viewer = viewer..addListener(sync);

  void sync() {
    if (viewer != null) datetime = viewer!.datetime;
    notifyListeners();
  }

  void pick(DateTime datetime) {
    this.datetime = datetime;
    viewer?.jump(datetime);
    notifyListeners();
  }

  @override
  void dispose() {
    viewer?.removeListener(sync);
    super.dispose();
  }
}