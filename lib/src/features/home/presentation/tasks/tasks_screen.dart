import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/presentation/tasks/controller/tasks_controller.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';
import 'package:ugz_app/src/widgets/emoticons.dart';
import 'package:ugz_app/src/widgets/list_item.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(tasksControllerProvider.notifier).getTasks(),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(tasksControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksControllerProvider);

    return CustomView(
      header: CustomViewHeader(
        children: [
          IconButton(
            onPressed: () => ref.read(routerConfigProvider).pop(),
            icon: const FaIcon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n!.tasks,
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(tasksControllerProvider.notifier).getTasks();
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (state.isLoading && state.tasks.isEmpty)
              SizedBox(
                height: context.height * .9,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.tasks.isEmpty)
              SizedBox(
                height: context.height * .9,
                child: Emoticons(text: 'Error: ${state.error}'),
              )
            else if (state.tasks.isEmpty)
              Emoticons(text: context.l10n!.no_tasks_found)
            else ...[
              ListView.separated(
                itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == state.tasks.length) {
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

                  var task = state.tasks[index];
                  return ListItem(
                    onPressed: () => TaskRoute(taskId: task.id).push(context),
                    title: task.taskName,
                    prefixIconPath: Assets.icons.guard.path,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
