import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/providers/history_pending_providers.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/widgets/emoticons.dart';
import 'package:ugz_app/src/widgets/list_item.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class HistoryPendingSection extends ConsumerWidget {
  const HistoryPendingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access AsyncValue<Stream<List<PendingFormsModel>>>
    final asyncController = ref.watch(historyPendingProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: asyncController.when(
            data: (stream) {
              return StreamBuilder<List<PendingFormsModel>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show loading indicator while waiting for stream data
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    // Show error message if stream has an error
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final pendingForms = snapshot.data ?? [];

                  // Show a message if the data is empty
                  if (pendingForms.isEmpty) {
                    return const Emoticons(text: "No pending forms found");
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(historyPendingProvider.future),
                    child: ListView.separated(
                      itemCount: pendingForms.length,
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final form = pendingForms[index];

                        final iconPath =
                            form.category == 1
                                ? Assets.icons.file.path
                                : form.category == 2
                                ? Assets.icons.checklist.path
                                : Assets.icons.guard.path;

                        return ListItem(
                          title: form.description,
                          subtitle: DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(form.timestamp.toLocal()),
                          prefixIconPath: iconPath,
                          suffix: const SizedBox(),
                          onPressed: () {},
                          // onPressed:
                          //     () => ref
                          //         .read(routerProvider)
                          //         .push(Routes.MAPS, extra: form.toJson()),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ElevatedButton(
            // onPressed:
            //     () => ref.refresh(historyPendingProvider.future),
            onPressed: () {},
            child: Text(
              context.l10n!.retry_upload,
              style: context.textTheme.labelMedium!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
