import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signature/signature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/presentation/task/controller/task_controller.dart';
import 'package:ugz_app/src/features/home/widgets/mixin/form_field_mixin.dart';
import 'package:ugz_app/src/features/home/widgets/success_submit_dialog.dart';
import 'package:ugz_app/src/global_providers/location_providers.dart';
import 'package:ugz_app/src/local/record/form_data.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class TaskScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen>
    with FormFieldMixin<TaskFields> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final Map<String, dynamic> formValues = {};
  double? latitude;
  double? longitude;

  final Map<String, SignatureController> _signatureControllers = {};

  @override
  void dispose() {
    for (var controller in _signatureControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the custom TaskState
    final taskState = ref.watch(taskControllerProvider(widget.taskId));

    // Listen for state changes
    ref.listen(taskControllerProvider(widget.taskId), (prev, next) {
      if (!prev!.isSubmitSuccess && next.isSubmitSuccess) {
        showSuccessDialog(context, ref, formType: "Task");
      }

      if (next.error != null && prev.error != next.error) {
        context.showSnackBar("An error occurred: ${next.error}");
      }
    });

    return GestureDetector(
      onTap: () => context.hideKeyboard(),
      child: CustomView(
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: BottomAppBar(
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: ElevatedButton(
              onPressed:
                  taskState.isSubmitting ||
                          taskState.isLoading ||
                          taskState.task == null
                      ? null
                      : _submitForm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (taskState.isSubmitting)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  if (taskState.isSubmitting) const SizedBox(width: 8),
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
                  taskState.isSubmitting
                      ? null
                      : () => ref.read(routerConfigProvider).pop(),
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            if (taskState.isLoading)
              const Text("Loading...", style: TextStyle(color: Colors.white))
            else if (taskState.error != null)
              const Text("Error", style: TextStyle(color: Colors.white))
            else
              Text(
                taskState.task?.taskName ?? "Task",
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (taskState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (taskState.error != null) {
              return Center(child: Text("Error: ${taskState.error}"));
            }

            final task = taskState.task;
            if (task == null) {
              return const Center(child: Text("Task not found"));
            }

            // Initialize signature controllers if needed
            if (_signatureControllers.isEmpty) {
              for (var field in task.fields) {
                if (field.fieldTypeId == "5") {
                  _signatureControllers[field.id] = SignatureController(
                    penStrokeWidth: 5,
                    penColor: Colors.lightGreen,
                    exportBackgroundColor: Colors.transparent,
                  );
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        task.fields.map((field) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: _buildFormField(field),
                          );
                        }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormField(TaskFields field) {
    return buildFormField(
      FormType.TASKS,
      field,
      formValues,
      _signatureControllers,
      (String id, dynamic value) {
        setState(() {
          formValues[id] = value;
        });
      },
    );
  }

  Future<LocationStatus> _validateLocation() async {
    final locationData = await ref.read(locationProvider.future);

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

  void _submitForm() async {
    if (!(_key.currentState?.validate() ?? false)) return;

    try {
      final task = ref.read(taskControllerProvider(widget.taskId)).task;
      if (task == null) {
        context.showSnackBar("Task data not available");
        return;
      }

      final locationStatus = await _validateLocation();
      if (locationStatus != LocationStatus.granted) {
        return;
      }

      final userId = ref.read(userDataProvider).valueOrNull?.id ?? 0;
      final formData = _generateFormData(task);

      await ref
          .read(taskControllerProvider(widget.taskId).notifier)
          .submit(
            partitionKey: "user:$userId",
            timestamp: DateTime.now().toUtc().toIso8601String(),
            latitude: latitude,
            longitude: longitude,
            description: task.taskName,
            formId: task.id,
            data: formData,
          );
    } catch (e) {
      context.showSnackBar("Error: $e");
    }
  }

  FormData _generateFormData(TaskModel task) {
    return FormData(
      comments:
          task.fields
              .where(
                (field) => field.fieldTypeId == "2" || field.fieldTypeId == "1",
              )
              .map(
                (field) => FormStringEntry(
                  id: int.tryParse(field.id) ?? 0,
                  inputName: field.taskFieldName,
                  value: formValues[field.id] ?? "",
                ),
              )
              .toList(),
      switches:
          task.fields
              .where((field) => field.fieldTypeId == "3")
              .map(
                (field) => FormStringEntry(
                  id: int.tryParse(field.id) ?? 0,
                  inputName: field.taskFieldName,
                  value: (formValues[field.id] ?? false).toString(),
                ),
              )
              .toList(),
      photos:
          task.fields
              .where((field) => field.fieldTypeId == "4")
              .map(
                (field) => FormFileEntry(
                  id: int.tryParse(field.id) ?? 0,
                  inputName: field.taskFieldName,
                  value: formValues[field.id]?.toString() ?? "",
                ),
              )
              .toList(),
      signatures:
          task.fields
              .where((field) => field.fieldTypeId == "5")
              .map(
                (field) => FormFileEntry(
                  id: int.tryParse(field.id) ?? 0,
                  inputName: field.taskFieldName,
                  value: formValues[field.id]?.toString() ?? "",
                ),
              )
              .toList(),
      selects:
          task.fields
              .where((field) => field.fieldTypeId == "6")
              .map(
                (field) => FormSelectEntry(
                  id: int.tryParse(field.id) ?? 0,
                  inputName: field.taskFieldName,
                  pickListId: 0,
                  pickListName: "",
                  value: formValues[field.id]?.toString() ?? "",
                  pickListOptionName: "",
                  pos: 0,
                ),
              )
              .toList(),
    );
  }
}
