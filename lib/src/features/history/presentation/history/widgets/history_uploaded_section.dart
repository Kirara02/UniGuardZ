import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/providers/history_uploaded_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/emoticons.dart';
import 'package:ugz_app/src/widgets/list_item.dart';

// class HistoryUploadedSection extends ConsumerStatefulWidget {
//   const HistoryUploadedSection({super.key});
//
//   @override
//   ConsumerState<HistoryUploadedSection> createState() =>
//       _HistoryUploadedSectionState();
// }
//
// class _HistoryUploadedSectionState
//     extends ConsumerState<HistoryUploadedSection> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(
//       () => ref.read(historyUploadedProvider.notifier).getLogs(),
//     );
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       ref.read(historyUploadedProvider.notifier).loadMore();
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final historyAsync = ref.watch(historyUploadedProvider);
//
//     return RefreshIndicator(
//       onRefresh: () => ref.read(historyUploadedProvider.notifier).getLogs(),
//       child: switch (historyAsync) {
//         AsyncData(:final value) =>
//           value.isEmpty
//               ? Emoticons(text: context.l10n!.no_history_found)
//               : ListView.separated(
//                 controller: _scrollController,
//                 itemCount: value.logs.length + (value.hasMore ? 1 : 0),
//                 padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 separatorBuilder:
//                     (context, index) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   if (index == value.length) {
//                     return const Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   }
//
//                   final historyItem = value[index];
//                   Widget? icon;
//
//                   // Determine icon based on type
//                   switch (historyItem.payloadData['type'].toLowerCase()) {
//                     case 'form':
//                       icon = Assets.icons.file.svg(width: 20, height: 20);
//                     case 'task':
//                       icon = Assets.icons.checklist.svg(width: 20, height: 20);
//                     case 'activity':
//                       icon = Assets.icons.guard.svg(width: 20, height: 20);
//                     case 'user':
//                       icon =
//                           icon = Icon(
//                             Icons.person_outline_rounded,
//                             color: Colors.blue,
//                           );
//                     case 'alarm':
//                       icon = Icon(
//                         Icons.warning_amber_rounded,
//                         color: Colors.blue,
//                       );
//                     case 'checkpoint':
//                       icon = Icon(Icons.wifi_tethering, color: Colors.blue);
//                     default:
//                       icon = Assets.icons.pinLocation.svg(
//                         width: 20,
//                         height: 20,
//                       );
//                   }
//
//                   return ListItem(
//                     title:
//                         historyItem.payloadData['type'] != 'alarm'
//                             ? historyItem.referenceName
//                             : historyItem.alertEventName,
//                     subtitle: DateFormat('dd MMM yyyy, hh:mm a').format(
//                       DateTime.parse(
//                         historyItem.originalSubmittedTime,
//                       ).toLocal(),
//                     ),
//                     prefix: icon,
//                     suffix: InkWell(
//                       onTap:
//                           () => HistoryDetailRoute(
//                             historyId: historyItem.id,
//                             historyType: HistoryType.uploaded.value,
//                           ).push(context),
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: context.colorScheme.outlineVariant,
//                           ),
//                         ),
//                         child: Assets.icons.pinLocation.svg(),
//                       ),
//                     ),
//                     onPressed:
//                         () => HistoryDetailRoute(
//                           historyId: historyItem.id,
//                           historyType: HistoryType.uploaded.value,
//                         ).push(context),
//                   );
//                 },
//               ),
//
//         _ => const Center(child: CircularProgressIndicator()),
//       },
//     );
//   }
// }

class HistoryUploadedSection extends ConsumerStatefulWidget {
  const HistoryUploadedSection({super.key});

  @override
  ConsumerState<HistoryUploadedSection> createState() =>
      _HistoryUploadedSectionState();
}

class _HistoryUploadedSectionState extends ConsumerState<HistoryUploadedSection>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(historyUploadedProvider.notifier).getLogs(),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final current = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    if (current >= max - 200) {
      ref.read(historyUploadedProvider.notifier).loadMore();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(historyUploadedProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(historyUploadedProvider.notifier).getLogs(),
      child:
          state.isLoading && state.logs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.error != null && state.logs.isEmpty
              ? Center(child: Emoticons(text: 'Error: ${state.error}'))
              : state.logs.isEmpty
              ? Emoticons(text: context.l10n!.no_history_found)
              : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 60),
                itemCount: state.logs.length + (state.hasMore ? 1 : 0),
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == state.logs.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            state.isLoadingMore
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                      ),
                    );
                  }

                  final historyItem = state.logs[index];
                  Widget? icon;

                  // Determine icon based on type
                  switch (historyItem.payloadData['type'].toLowerCase()) {
                    case 'form':
                      icon = Assets.icons.file.svg(width: 20, height: 20);
                    case 'task':
                      icon = Assets.icons.checklist.svg(width: 20, height: 20);
                    case 'activity':
                      icon = Assets.icons.guard.svg(width: 20, height: 20);
                    case 'user':
                      icon = Icon(
                        Icons.person_outline_rounded,
                        color: Colors.blue,
                      );
                    case 'alarm':
                      icon = Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.blue,
                      );
                    case 'checkpoint':
                      icon = Icon(Icons.wifi_tethering, color: Colors.blue);
                    default:
                      icon = Assets.icons.pinLocation.svg(
                        width: 20,
                        height: 20,
                      );
                  }

                  return ListItem(
                    title:
                        historyItem.payloadData['type'] != 'alarm'
                            ? historyItem.referenceName
                            : historyItem.alertEventName,
                    subtitle: DateFormat('dd MMM yyyy, hh:mm a').format(
                      DateTime.parse(
                        historyItem.originalSubmittedTime,
                      ).toLocal(),
                    ),
                    prefix: icon,
                    suffix: InkWell(
                      onTap:
                          () => HistoryDetailRoute(
                            historyId: historyItem.id,
                            historyType: HistoryType.uploaded.value,
                          ).push(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Assets.icons.pinLocation.svg(),
                      ),
                    ),
                    onPressed:
                        () => HistoryDetailRoute(
                          historyId: historyItem.id,
                          historyType: HistoryType.uploaded.value,
                        ).push(context),
                  );
                },
              ),
    );
  }
}
