import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/home/presentation/activity/controller/activity_controller.dart';
import 'package:ugz_app/src/features/home/widgets/form/photo_field.dart';
import 'package:ugz_app/src/features/home/widgets/form/text_field.dart';
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
  bool isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(
      activityControllerProvider(widget.activityId),
    );

    ref.listen(activityControllerProvider(widget.activityId), (prev, next) {
      if (prev is AsyncLoading && next is AsyncData) {
        _setLoading(false);
        _showSuccessDialog();
      }

      if (next is AsyncError) {
        context.showSnackBar("An error occurred: ${next.error}");
      }
    });

    return GestureDetector(
      onTap: () => context.hideKeyboard(),
      child: CustomView(
        bottomNavigationBar: BottomAppBar(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitForm,
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Submit"),
            ),
          ),
        ),
        header: CustomViewHeader(
          children: [
            IconButton(
              onPressed: isLoading ? null : () => HomeRoute().go(context),
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            activityAsync.when(
              data:
                  (activity) => Text(
                    activity?.activityName ?? "Activity",
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
              loading:
                  () => const Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white),
                  ),
              error:
                  (_, __) => const Text(
                    "Error",
                    style: TextStyle(color: Colors.white),
                  ),
            ),
          ],
        ),
        body: activityAsync.when(
          data: (activity) {
            if (activity == null) {
              // return const Center(child: Text("Activity not found"));
              return const SizedBox.shrink();
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text("Error: $error")),
        ),
      ),
    );
  }

  Future<LocationStatus> _validateLocation() async {
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
    _setLoading(true);

    try {
      final userId = ref.read(userDataProvider).valueOrNull?.id;
      final activity =
          ref.read(activityControllerProvider(widget.activityId)).valueOrNull;

      if (activity == null) {
        context.showSnackBar("Activity data not available");
        _setLoading(false);
        return;
      }

      if (activity.gpsRequired) {
        final locationStatus = await _validateLocation();
        if (locationStatus != LocationStatus.granted) {
          _setLoading(false);
          return;
        }
      }

      await ref
          .read(activityControllerProvider(widget.activityId).notifier)
          .submit(
            partitionKey: "user:${userId ?? 0}",
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
            ),
          );
    } catch (e) {
      if (mounted) {
        context.showSnackBar("Submission failed: \$e");
      }
    } finally {
      _setLoading(false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your activity has been added successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  HomeRoute().go(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
