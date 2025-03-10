import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signature/signature.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/presentation/form/controller/form_controller.dart';
import 'package:ugz_app/src/features/home/widgets/mixin/form_field_mixin.dart';
import 'package:ugz_app/src/global_providers/location_providers.dart';
import 'package:ugz_app/src/local/record/form_data.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class FormScreen extends ConsumerStatefulWidget {
  final String formId;
  const FormScreen({super.key, required this.formId});

  @override
  ConsumerState<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends ConsumerState<FormScreen>
    with FormFieldMixin<FormFields> {
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
    final textTheme = context.textTheme;
    // Use the custom FormState
    final formState = ref.watch(formControllerProvider(widget.formId));

    // Listen for state changes
    ref.listen(formControllerProvider(widget.formId), (prev, next) {
      if (!prev!.isSubmitSuccess && next.isSubmitSuccess) {
        _showSuccessDialog();
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
                  formState.isSubmitting ||
                          formState.isLoading ||
                          formState.form == null
                      ? null
                      : _submitForm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (formState.isSubmitting)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  if (formState.isSubmitting) const SizedBox(width: 8),
                  Text(context.l10n!.submit),
                ],
              ),
            ),
          ),
        ),
        header: CustomViewHeader(
          children: [
            IconButton(
              onPressed:
                  formState.isSubmitting
                      ? null
                      : () => ref.read(routerConfigProvider).pop(),
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            if (formState.isLoading)
              const Text("Loading...", style: TextStyle(color: Colors.white))
            else if (formState.error != null)
              const Text("Error", style: TextStyle(color: Colors.white))
            else
              Text(
                formState.form?.formName ?? "Form",
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (formState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (formState.error != null) {
              return Center(child: Text("Error: ${formState.error}"));
            }

            final form = formState.form;
            if (form == null) {
              return const Center(child: Text("Form not found"));
            }

            // Initialize signature controllers if needed
            if (_signatureControllers.isEmpty) {
              for (var field in form.fields) {
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
                        form.fields.map((field) {
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

  Widget _buildFormField(FormFields field) {
    return buildFormField(
      FormType.FORMS,
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
      final form = ref.read(formControllerProvider(widget.formId)).form;
      if (form == null) {
        context.showSnackBar("Form data not available");
        return;
      }

      // Validate required fields
      for (var field in form.fields) {
        if (field.formFieldRequire &&
            (formValues[field.id] == null ||
                formValues[field.id].toString().isEmpty)) {
          context.showSnackBar('Field ${field.formFieldName} is required');
          return;
        }
      }

      // Validate photos
      for (var field in form.fields) {
        if (field.fieldTypeId == "4" &&
            field.formFieldRequire &&
            formValues[field.id] == null) {
          context.showSnackBar('Photo ${field.formFieldName} is required');
          return;
        }
      }

      // Validate signatures
      for (var field in form.fields) {
        if (field.fieldTypeId == "5" &&
            field.formFieldRequire &&
            formValues[field.id] == null) {
          context.showSnackBar('Signature ${field.formFieldName} is required');
          return;
        }
      }

      final locationStatus = await _validateLocation();
      if (locationStatus != LocationStatus.granted) {
        return;
      }

      final userId = ref.read(userDataProvider).valueOrNull?.id ?? 0;
      final formData = _generateFormData(form);

      await ref
          .read(formControllerProvider(widget.formId).notifier)
          .submit(
            partitionKey: "user:$userId",
            timestamp: DateTime.now().toUtc().toIso8601String(),
            latitude: latitude,
            longitude: longitude,
            description: form.formName,
            formId: form.id,
            data: formData,
          );
    } catch (e) {
      context.showSnackBar("Submission failed: $e");
    }
  }

  FormData _generateFormData(FormModel form) {
    return FormData(
      comments:
          form.fields
              .where(
                (field) =>
                    field.fieldTypeId == FieldTypes.text.value.toString() ||
                    field.fieldTypeId == FieldTypes.input.value.toString(),
              )
              .map(
                (field) => FormStringEntry(
                  id: field.id.toInt,
                  inputName: field.formFieldName,
                  value: formValues[field.id],
                ),
              )
              .toList(),
      switches:
          form.fields
              .where(
                (field) =>
                    field.fieldTypeId == FieldTypes.checkbox.value.toString(),
              )
              .map(
                (field) => FormStringEntry(
                  id: field.id.toInt,
                  inputName: field.formFieldName,
                  value: formValues[field.id]?.toString(),
                ),
              )
              .toList(),
      photos:
          form.fields
              .where(
                (field) =>
                    field.fieldTypeId == FieldTypes.image.value.toString(),
              )
              .map(
                (field) => FormFileEntry(
                  id: field.id.toInt,
                  inputName: field.formFieldName,
                  value: formValues[field.id]?.toString(),
                ),
              )
              .toList(),
      signatures:
          form.fields
              .where(
                (field) =>
                    field.fieldTypeId == FieldTypes.signature.value.toString(),
              )
              .map(
                (field) => FormFileEntry(
                  id: field.id.toInt,
                  inputName: field.formFieldName,
                  value: formValues[field.id]?.toString(),
                ),
              )
              .toList(),
      selects:
          form.fields.where((field) => field.fieldTypeId == "6").map((field) {
            final option = field.picklist?.options.firstWhere(
              (option) => option.id == formValues[field.id],
            );
            return FormSelectEntry(
              id: field.id.toInt,
              inputName: field.formFieldName,
              pickListId: field.formPicklistId?.toInt ?? 0,
              pickListName: field.picklist?.options.first.name,
              value: option?.id.toString(),
              pickListOptionName: option?.name,
              pos: int.parse(formValues[field.id] ?? "0"),
            );
          }).toList(),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Your form has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(routerConfigProvider).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
