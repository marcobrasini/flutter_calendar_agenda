import '../const.dart';


class Callbacks {
  const Callbacks({
    this.onEventTap,
    this.onEventDoubleTap,
    this.onEventLongPress,
    this.onFrameTap,
    this.onFrameDoubleTap,
    this.onFrameLongPress,
    this.onEventCreated,
    this.onEventUpdated,
    this.onEventDeleted,
    this.onEventDragged,
    this.onEventResized,
    this.onEventSwipedLeft,
    this.onEventSwipedRight,
  });

  final SlotCallback? onEventTap;
  final SlotCallback? onEventDoubleTap;
  final SlotCallback? onEventLongPress;
  final PageCallback? onFrameTap;
  final PageCallback? onFrameDoubleTap;
  final PageCallback? onFrameLongPress;
  final CreateCallback? onEventCreated;
  final ModifyCallback? onEventUpdated;
  final DeleteCallback? onEventDeleted;
  final ModifyCallback? onEventDragged;
  final ModifyCallback? onEventResized;
  final ModifyCallback? onEventSwipedLeft;
  final ModifyCallback? onEventSwipedRight;
}
