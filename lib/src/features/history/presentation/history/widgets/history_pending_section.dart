import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/providers/history_pending_providers.dart';
import 'package:ugz_app/src/features/history/providers/retry_upload_providers.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/usecases/delete_pending_forms_by_id/delete_pending_forms_by_id.dart';
import 'package:ugz_app/src/local/usecases/delete_pending_forms_by_id/delete_pending_forms_by_id_params.dart';
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
    final selectionState = ref.watch(pendingFormsSelectionProvider);
    final isSelectionMode = selectionState.isNotEmpty;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 60),
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
                    return Emoticons(
                      text: context.l10n!.no_pending_forms_found,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n!.press_long_delete_item,
                        style: context.textTheme.labelSmall!.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh:
                              () => ref.refresh(historyPendingProvider.future),
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

                              final isSelected = ref
                                  .watch(pendingFormsSelectionProvider)
                                  .contains(form.id);

                              return ListItem(
                                title: form.description,
                                subtitle: DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(
                                  DateTime.parse(form.timestamp).toLocal(),
                                ),
                                prefixIconPath: iconPath,
                                suffix:
                                    isSelectionMode
                                        ? Checkbox(
                                          value: isSelected,
                                          onChanged: (value) {
                                            ref
                                                .read(
                                                  pendingFormsSelectionProvider
                                                      .notifier,
                                                )
                                                .toggleSelection(form.id);
                                          },
                                        )
                                        : isUploading
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
                                              () => _retryUpload(
                                                context,
                                                ref,
                                                form,
                                              ),
                                        ),
                                onPressed:
                                    isSelectionMode
                                        ? () => ref
                                            .read(
                                              pendingFormsSelectionProvider
                                                  .notifier,
                                            )
                                            .toggleSelection(form.id)
                                        : () => HistoryDetailRoute(
                                          historyId: form.formId,
                                          historyType:
                                              HistoryType.pending.value,
                                        ).push(context),
                                onLongPress: () {
                                  ref
                                      .read(
                                        pendingFormsSelectionProvider.notifier,
                                      )
                                      .toggleSelection(form.id);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      isSelectionMode
                          ? () => _deleteSelected(context, ref)
                          : uploadingState.isUploading
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
                        isSelectionMode
                            ? context.l10n!.delete
                            : context.l10n!.retry_upload,
                        style: context.textTheme.labelMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed:
                      () =>
                          ref
                              .read(pendingFormsSelectionProvider.notifier)
                              .clearSelection(),
                ),
            ],
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

  void _deleteSelected(BuildContext context, WidgetRef ref) async {
    final selectedIds = ref.read(pendingFormsSelectionProvider);
    final deletePendingFormsById = ref.read(dbDeletePendingFormsByIdProvider);

    for (final id in selectedIds) {
      await deletePendingFormsById(DeletePendingFormsByIdParams(id: id));
    }

    ref.read(pendingFormsSelectionProvider.notifier).clearSelection();

    if (context.mounted) {
      context.showSnackBar("Successfully deleted selected forms");
    }
  }
}
