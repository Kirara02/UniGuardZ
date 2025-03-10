import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/features/history/presentation/history/widgets/history_pending_section.dart';
import 'package:ugz_app/src/features/history/presentation/history/widgets/history_uploaded_section.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: context.colorScheme.surface,
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: context.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 4,
              ),
              labelColor: context.colorScheme.onPrimary,
              unselectedLabelColor: context.colorScheme.outline,
              labelStyle: context.textTheme.labelMedium,
              unselectedLabelStyle: context.textTheme.labelMedium,
              tabs: [
                Tab(text: context.l10n!.uploaded),
                Tab(text: context.l10n!.pending),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                HistoryUploadedSection(),
                HistoryPendingSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
