import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/home/presentation/activity/controller/activity_controller.dart';
import 'package:ugz_app/src/features/home/widgets/form/photo_field.dart';
import 'package:ugz_app/src/features/home/widgets/form/text_field.dart';
import 'package:ugz_app/src/features/home/widgets/success_submit_dialog.dart';
import 'package:ugz_app/src/global_providers/location_providers.dart';
import 'package:ugz_app/src/local/record/form_data.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String? commentValue;
  String? photoPath;
  double? latitude;
  double? longitude;

  @override
  Widget build(BuildContext context) {
    // Use the custom ActivityState
    final activityState = ref.watch(
      activityControllerProvider(widget.activityId),
    );

    // Listen for state changes
    ref.listen(activityControllerProvider(widget.activityId), (prev, next) {
      if (!prev!.isSubmitSuccess && next.isSubmitSuccess) {
        showSuccessDialog(context, ref, formType: context.l10n!.activity);
      }

      if (next.error != null && prev.error != next.error) {
        context.showSnackBar("Error: ${next.error}");
      }
    });

    return GestureDetector(
      onTap: () => context.hideKeyboard(),
      child: CustomView(
        bottomNavigationBar: BottomAppBar(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed:
                  activityState.isSubmitting ||
                          activityState.isLoading ||
                          activityState.activity == null
                      ? null
                      : _submitForm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (activityState.isSubmitting)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  if (activityState.isSubmitting) const SizedBox(width: 8),
                  const Text("Submit"),
                ],
              ),
            ),
          ),
        ),
        header: CustomViewHeader(
          children: [
            IconButton(
              onPressed:
                  activityState.isSubmitting
                      ? null
                      : () => ref.watch(routerConfigProvider).pop(),
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            if (activityState.isLoading)
              const Text("Loading...", style: TextStyle(color: Colors.white))
            else if (activityState.error != null)
              const Text("Error", style: TextStyle(color: Colors.white))
            else
              Text(
                activityState.activity?.activityName ?? "Activity",
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (activityState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (activityState.error != null) {
              return Center(child: Text("Error: ${activityState.error}"));
            }

            final activity = activityState.activity;
            if (activity == null) {
              return const Center(child: Text("Activity not found"));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activity.commentRequired)
                      CustomTextFieldVertical(
                        label: "Comments",
                        value: commentValue,
                        isActive: true,
                        keyboardType: TextInputType.multiline,
                        onChanged:
                            (value) => setState(() => commentValue = value),
                      ),
                    if (activity.photoRequired)
                      PhotoFieldVertical(
                        label: "Photo",
                        value: photoPath,
                        isActive: true,
                        onImagePicked:
                            (imagePath) =>
                                setState(() => photoPath = imagePath),
                      ),
                    if (activity.gpsRequired)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "* Location is required",
                          style: context.textTheme.labelSmall!.copyWith(
                            color: context.colorScheme.errorContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<LocationStatus> _validateLocation() async {
    // Refresh trigger untuk memaksa provider re-run
    ref.read(locationTriggerProvider.notifier).state++;

    final locationData = await ref.read(locationProvider.future);

    if (mounted) {
      switch (locationData.status) {
        case LocationStatus.serviceDisabled:
          context.showSnackBar("GPS is not active");
          return LocationStatus.serviceDisabled;
        case LocationStatus.denied:
          context.showSnackBar("Location permission denied");
          return LocationStatus.denied;
        case LocationStatus.unknown:
          context.showSnackBar("Failed to get location");
          return LocationStatus.unknown;
        case LocationStatus.granted:
          latitude = locationData.position?.latitude;
          longitude = locationData.position?.longitude;
          return LocationStatus.granted;
      }
    }

    return LocationStatus.unknown;
  }

  void _submitForm() async {
    if (!(_key.currentState?.validate() ?? false)) return;

    try {
      final activity =
          ref.read(activityControllerProvider(widget.activityId)).activity;
      if (activity == null) {
        context.showSnackBar("Activity data not available");
        return;
      }

      // Set loading state before starting any process
      ref
          .read(activityControllerProvider(widget.activityId).notifier)
          .setSubmitting(true);

      // Validate required fields
      if (activity.commentRequired &&
          (commentValue == null || commentValue!.isEmpty)) {
        context.showSnackBar("Comment is required");
        ref
            .read(activityControllerProvider(widget.activityId).notifier)
            .setSubmitting(false);
        return;
      }

      if (activity.photoRequired && photoPath == null) {
        context.showSnackBar("Photo is required");
        ref
            .read(activityControllerProvider(widget.activityId).notifier)
            .setSubmitting(false);
        return;
      }

      if (activity.gpsRequired) {
        final locationStatus = await _validateLocation();
        if (locationStatus != LocationStatus.granted) {
          ref
              .read(activityControllerProvider(widget.activityId).notifier)
              .setSubmitting(false);
          return;
        }
      }

      final userId = ref.read(userDataProvider).valueOrNull?.id ?? 0;

      await ref
          .read(activityControllerProvider(widget.activityId).notifier)
          .submit(
            partitionKey: "user:$userId",
            timestamp: DateTime.now().toUtc().toIso8601String(),
            latitude: latitude,
            longitude: longitude,
            description: activity.activityName,
            formId: activity.id,
            data: FormData(
              comments:
                  commentValue != null
                      ? [
                        FormStringEntry(
                          id: 1,
                          inputName: "Comments",
                          value: commentValue!,
                        ),
                      ]
                      : [],
              photos:
                  photoPath != null
                      ? [
                        FormFileEntry(
                          id: 1,
                          inputName: "Photo",
                          value: photoPath!,
                        ),
                      ]
                      : [],
              switches: [],
              signatures: [],
              selects: [],
            ),
          );
    } catch (e) {
      context.showSnackBar("Error: $e");
      ref
          .read(activityControllerProvider(widget.activityId).notifier)
          .setSubmitting(false);
    }
  }
}
