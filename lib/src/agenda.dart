import 'package:flutter/material.dart';
import 'package:calendar/src/base.dart';
import 'widgets/calendar_agenda.dart';
import 'utils/schemes.dart';
import 'data/event.dart';


class Agenda<T extends Event> extends CalendarBase<T> {
  const Agenda({
    super.key,
    required super.source,
    required super.view,
    required super.scroll,
    super.dateScheme,
    //
    super.headerConfig,
    super.eventConfig,
    super.clockConfig,
    super.dateConfig,
    super.lineConfig,
    //
    super.headerBuilder,
    super.eventBuilder,
    super.leftSwipeBuilder,
    super.rightSwipeBuilder,
    //
    super.draggableEvent = true,
    super.swipeableEvent = true,
    //
    super.showFrame = true,
    super.showHeader = true,
    super.showHeaderWidget = true,
    super.showHeaderButton = true,
    super.showIndicator = true,
    super.fixLastAnchor = true,
    super.fixNextAnchor = true,
    super.negligibleAgenda = false,
    super.shrinkableAgenda = false,
    //
    super.onEventTap,
    super.onEventDoubleTap,
    super.onEventLongPress,
    super.onFrameTap,
    super.onFrameDoubleTap,
    super.onFrameLongPress,
    super.onEventDragged,
    super.onEventSwipedLeft,
    super.onEventSwipedRight,
    super.lastAnchorBuilder,
    super.nextAnchorBuilder,
    super.emptyBuilder,
    super.centredView,
  });

  @override
  Widget buildViewer(BuildContext context,
      DateScheme dateScheme,
      TimeScheme? timeScheme,
      WeekScheme? weekScheme,
  ) {
    // return CustomScrollView(
    //   primary: false,
    //   slivers: [
    //     SliverLayoutBuilder(
    //       builder: (context, constraints) => SliverToBoxAdapter(
    //         child: SizedBox(
    //           height: constraints.viewportMainAxisExtent -
    //           constraints.precedingScrollExtent,
    //           child: CalendarAgenda(
    //             dateScheme: dateScheme,
    //             callbacks: callbacks,
    //             scrolling: scroll,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
    return CalendarAgenda(
      dateScheme: dateScheme,
      scrolling: scroll,
    );
  }
}