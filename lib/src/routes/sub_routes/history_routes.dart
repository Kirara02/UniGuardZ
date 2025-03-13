part of '../router_config.dart';

class HistoryRoute extends GoRouteData {
  const HistoryRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: HistoryScreen());
}

class HistoryDetailData extends GoRouteData {
  const HistoryDetailData({required this.historyId, required this.historyType});

  final String historyId;
  final String historyType;

  static final $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      HistoryDetailScreen(
        historyId: historyId,
        historyType: HistoryType.fromValue(historyType),
      );
}
