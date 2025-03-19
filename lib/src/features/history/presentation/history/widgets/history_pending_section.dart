import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/providers/history_pending_providers.dart';
import 'package:ugz_app/src/features/history/providers/retry_upload_providers.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/widgets/emoticons.dart';
import 'package:ugz_app/src/widgets/list_item.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class HistoryPendingSection extends ConsumerWidget {
  const HistoryPendingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncController = ref.watch(historyPendingProvider);
    final uploadingState = ref.watch(retryUploadStateNotifierProvider);

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
                        printIfDebug(form.toJson());

                        final iconPath =
                            form.category == 1
                                ? Assets.icons.file.path
                                : form.category == 2
                                ? Assets.icons.checklist.path
                                : Assets.icons.guard.path;

                        final isUploading =
                            uploadingState.isUploading &&
                            uploadingState.currentItemId == form.id;

                        return ListItem(
                          title: form.description,
                          subtitle: DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(form.timestamp.toLocal()),
                          prefixIconPath: iconPath,
                          suffix:
                              isUploading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : IconButton(
                                    icon: const Icon(Icons.upload),
                                    onPressed:
                                        () => _retryUpload(context, ref, form),
                                  ),
                          onPressed:
                              () => HistoryDetailRoute(
                                historyId: form.formId,
                                historyType: HistoryType.pending.value,
                              ).push(context),
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
            onPressed:
                uploadingState.isUploading
                    ? null
                    : () => _retryUploadAll(context, ref),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (uploadingState.isUploading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                if (uploadingState.isUploading) const SizedBox(width: 8),
                Text(
                  context.l10n!.retry_upload,
                  style: context.textTheme.labelMedium!.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _retryUpload(
    BuildContext context,
    WidgetRef ref,
    PendingFormsModel form,
  ) async {
    final result = await ref
        .read(retryUploadProvider.notifier)
        .retryUploadSingle(form);

    if (result.isSuccess && context.mounted) {
      context.showSnackBar("Successfully uploaded ${form.description}");
    } else if (context.mounted) {
      context.showSnackBar("Failed to upload: ${result.errorMessage}");
    }
  }

  void _retryUploadAll(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(retryUploadProvider.notifier).retryUploadAll();

    if (result.isSuccess && context.mounted) {
      context.showSnackBar("Successfully uploaded all pending forms");
    } else if (context.mounted) {
      context.showSnackBar(
        "Some forms failed to upload: ${result.errorMessage}",
      );
    }
  }
}
