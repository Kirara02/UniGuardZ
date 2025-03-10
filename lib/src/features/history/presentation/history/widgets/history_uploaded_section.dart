import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/list_item.dart';

class HistoryUploadedSection extends ConsumerStatefulWidget {
  const HistoryUploadedSection({super.key});

  @override
  ConsumerState createState() => _HistoryUploadedSectionState();
}

class _HistoryUploadedSectionState
    extends ConsumerState<HistoryUploadedSection> {
  final items = [
    {
      "title": "File Upload",
      "subtitle": "10:45 05 Jan 2025",
      "prefixIconPath": Assets.icons.file.path,
    },
    {
      "title": "Task Submission",
      "subtitle": "14:30 04 Jan 2025",
      "prefixIconPath": Assets.icons.checklist.path,
    },
    {
      "title": "Cleaning Task",
      "subtitle": "08:15 06 Jan 2025",
      "prefixIconPath": Assets.icons.guard.path,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Tambahkan logika refresh di sini
        await Future.delayed(const Duration(seconds: 2)); // Simulasi refresh
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              return ListItem(
                title: item["title"]!,
                subtitle: item["subtitle"]!,
                prefixIconPath: item["prefixIconPath"]!,
                suffix: InkWell(
                  // onTap: () =>
                  //     ref.read(routerProvider).push(Routes.MAPS, extra: item),
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
                onPressed: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
