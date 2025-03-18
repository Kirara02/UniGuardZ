import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/providers/history_uploaded_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/list_item.dart';

class HistoryUploadedSection extends ConsumerWidget {
  const HistoryUploadedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyUploadedProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(historyUploadedProvider.notifier).refresh(),
      child: switch (historyAsync) {
        AsyncData(:final value) =>
          value.isEmpty
              ? Center(
                child: Text(
                  'No history found',
                  style: context.textTheme.bodyLarge,
                ),
              )
              : ListView.separated(
                itemCount: value.length,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
                physics: const AlwaysScrollableScrollPhysics(),
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = value[index];
                  String iconPath;

                  // Determine icon based on type
                  switch (item.payloadData['type'].toLowerCase()) {
                    case 'form':
                      iconPath = Assets.icons.file.path;
                    case 'task':
                      iconPath = Assets.icons.checklist.path;
                    case 'activity':
                      iconPath = Assets.icons.guard.path;
                    default:
                      iconPath = Assets.icons.pinLocation.path;
                  }

                  return ListItem(
                    title: item.referenceName,
                    subtitle: DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(DateTime.parse(item.originalSubmittedTime)),
                    prefixIconPath: iconPath,
                    suffix: InkWell(
                      onTap:
                          () => HistoryDetailRoute(
                            historyId: item.id,
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
                          historyId: item.id,
                          historyType: HistoryType.uploaded.value,
                        ).push(context),
                  );
                },
              ),
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${error.toString()}',
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    () => ref.read(historyUploadedProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
