import 'package:flutter/material.dart';
import 'widgets/calendar_header.dart';
import 'widgets/calendar_tabled.dart';
import 'utils/schemes.dart';
import 'data/event.dart';
import 'enums.dart';
import 'base.dart';


class Calendar<T extends Event> extends CalendarBase<T> {
  const Calendar({
    super.key,
    required super.source,
    required super.view,
    super.scroll = CalendarScroll.snapping,
    //
    super.dateScheme,
    super.timeScheme,
    super.weekScheme,
    //
    super.headerConfig,
    super.eventConfig,
    super.clockConfig,
    super.dateConfig,
    super.timeConfig,
    super.weekConfig,
    super.lineConfig,
    //
    super.headerBuilder,
    super.eventBuilder,
    super.leftSwipeBuilder,
    super.rightSwipeBuilder,
    super.cornerBuilder,
    //
    super.draggableEvent = true,
    super.resizableEvent = true,
    //
    super.showFrame = true,
    super.showHeader = true,
    super.showHeaderWidget = true,
    super.showHeaderButton = true,
    super.showIndicator = true,
    //
    super.onEventTap,
    super.onEventDoubleTap,
    super.onEventLongPress,
    super.onFrameTap,
    super.onFrameDoubleTap,
    super.onFrameLongPress,
    super.onEventDragged,
    super.onEventResized,
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
    //     SliverAppBar(
    //       pinned: true,
    //       automaticallyImplyLeading: false,
    //       automaticallyImplyActions: false,
    //       centerTitle: true,
    //       backgroundColor: headerConfig?.background,
    //       title: CalendarTabledHeader(),
    //     ),
    //     SliverLayoutBuilder(
    //       builder: (context, constraints) => SliverToBoxAdapter(
    //         child: SizedBox(
    //           height: constraints.viewportMainAxisExtent -
    //               constraints.precedingScrollExtent,
    //           child: CalendarTabled(
    //             slider: PrimaryScrollController.maybeOf(context),
    //             dateScheme: (view == CalendarView.daily)
    //                 ? DateScheme.daily()
    //                 : dateScheme,
    //             timeScheme: (view == CalendarView.monthly) ? null : timeScheme,
    //             weekScheme: (view == CalendarView.monthly) ? weekScheme : null,
    //             callbacks: callbacks,
    //             cornerWidget: cornerBuilder,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
    return Column(
      children: [
        CalendarTabledHeader(
          dateScheme: this.dateScheme ?? dateScheme,
          weekScheme: this.weekScheme ?? weekScheme,
        ),
        Expanded(
          child: CalendarTabled(
            dateScheme: (view == CalendarView.daily)
                ? DateScheme.daily()
                : dateScheme,
            timeScheme: (view == CalendarView.monthly) ? null : timeScheme,
            weekScheme: (view == CalendarView.monthly) ? weekScheme : null,
            cornerWidget: cornerBuilder,
          ),
        ),
      ],
    );
  }
}
