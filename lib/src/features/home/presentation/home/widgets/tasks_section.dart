import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/presentation/home/controller/home_controller.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/widgets/list_item.dart';
import 'package:ugz_app/src/widgets/navigator_header.dart';

class TasksSection extends ConsumerStatefulWidget {
  const TasksSection({super.key});

  @override
  ConsumerState<TasksSection> createState() => _TasksSectionState();
}

class _TasksSectionState extends ConsumerState<TasksSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tasksProvider.notifier).getTasks());
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(tasksProvider.notifier).getTasks();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          NavigatorHeader(title: context.l10n!.tasks),
          const Gap(16),
          tasks.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text("Forms empty"));
              }
              return ListView.separated(
                itemCount: data.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var task = data[index];
                  return ListItem(
                    // onPressed: () =>
                    //     ref.read(routerProvider).push(Routes.TASK, extra: task),
                    onPressed: () => TaskRoute(taskId: task.id).go(context),
                    title: task.taskName,
                    prefixIconPath: Assets.icons.checklist.path,
                  );
                },
              );
            },
            loading:
                () => SizedBox(
                  height: context.height * 0.9,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.grey),
                  ),
                ),
            error: (e, stack) {
              printIfDebug('Error fetching tasks: $e');
              return SizedBox(
                height: context.height * 0.9,
                child: Center(child: Text('Error: $e')),
              );
            },
          ),
        ],
      ),
    );
  }
}
