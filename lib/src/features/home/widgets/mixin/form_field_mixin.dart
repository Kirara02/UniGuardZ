import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/home/widgets/interface/base_field.dart';
import 'package:ugz_app/src/features/home/domain/model/field_model.dart';
import 'package:ugz_app/src/features/home/widgets/form/photo_field.dart';
import 'package:ugz_app/src/features/home/widgets/form/pick_list_field.dart';
import 'package:ugz_app/src/features/home/widgets/form/signature_field.dart';
import 'package:ugz_app/src/features/home/widgets/form/switch_field.dart';
import 'package:ugz_app/src/features/home/widgets/form/text_field.dart';

mixin FormFieldMixin<T extends BaseField> {
  Widget buildFormField(
    FormType fieldType,
    T field,
    Map<String, dynamic> formValues,
    Map<String, SignatureController> signatureControllers,
    Function(String, dynamic) onValueChanged,
  ) {
    final fieldTypeId = _getFieldTypeId(fieldType, field);
    final fieldName = _getFieldName(fieldType, field);
    final fieldId = _getFieldId(fieldType, field);
    final isActive = _getFieldActive(fieldType, field);
    final isRequired = _getFieldRequired(fieldType, field);
    final pickList = _getFieldPickList(fieldType, field);

    // Convert string fieldTypeId to int for enum matching
    final typeId = int.tryParse(fieldTypeId) ?? 0;
    final fieldTypes = FieldTypes.fromValue(typeId);

    switch (fieldTypes) {
      case FieldTypes.text:
      case FieldTypes.input:
      case FieldTypes.number:
      case FieldTypes.email:
        return buildTextField(
          fieldName,
          fieldId,
          isActive,
          isRequired,
          fieldTypes,
          formValues,
          onValueChanged,
          keyboardType: _getKeyboardType(fieldTypes),
        );
      case FieldTypes.image:
        return buildPhotoField(
          fieldName,
          fieldId,
          isActive,
          isRequired,
          formValues,
          onValueChanged,
        );
      case FieldTypes.checkbox:
        return buildSwitchField(
          fieldName,
          fieldId,
          isActive,
          isRequired,
          formValues,
          onValueChanged,
        );
      case FieldTypes.signature:
        return buildSignatureField(
          fieldName,
          fieldId,
          isActive,
          isRequired,
          formValues,
          signatureControllers,
          onValueChanged,
        );
      case FieldTypes.select:
        return buildPickListField(
          fieldName,
          fieldId,
          isActive,
          isRequired,
          formValues,
          onValueChanged,
          pickList,
        );
    }
  }

  // Add helper method to determine keyboard type
  TextInputType _getKeyboardType(FieldTypes type) {
    switch (type) {
      case FieldTypes.number:
        return TextInputType.number;
      case FieldTypes.email:
        return TextInputType.emailAddress;
      case FieldTypes.text:
        return TextInputType.multiline;
      case FieldTypes.input:
        return TextInputType.text;
      default:
        return TextInputType.multiline;
    }
  }

  TextInputAction _getTextInputAction(FieldTypes type) {
    return type == FieldTypes.text
        ? TextInputAction.newline
        : TextInputAction.done;
  }

  String _getFieldTypeId(FormType type, T field) {
    return field.IFieldTypeId;
  }

  String _getFieldName(FormType type, T field) {
    return field.IFieldName;
  }

  String _getFieldId(FormType type, T field) {
    return field.Iid;
  }

  bool _getFieldActive(FormType type, T field) {
    return field.IActive;
  }

  bool _getFieldRequired(FormType type, T field) {
    return field.IRequired;
  }

  PickList? _getFieldPickList(FormType type, T field) {
    return field.IPickList;
  }

  // Update TextField builder to accept keyboard type
  Widget buildTextField(
    String fieldName,
    String fieldId,
    bool isActive,
    bool required,
    FieldTypes fieldType,
    Map<String, dynamic> formValues,
    Function(String, dynamic) onValueChanged, {
    TextInputType keyboardType = TextInputType.multiline,
  }) {
    return CustomTextFieldVertical(
      isRequired: required,
      isActive: isActive,
      label: fieldName,
      value: formValues[fieldId],
      keyboardType: keyboardType,
      textInputAction: _getTextInputAction(fieldType),
      onChanged: (value) => onValueChanged(fieldId, value),
    );
  }

  Widget buildSignatureField(
    String fieldName,
    String fieldId,
    bool isActive,
    bool isRequired,
    Map<String, dynamic> formValues,
    Map<String, SignatureController> signatureControllers,
    Function(String, dynamic) onValueChanged,
  ) {
    final signatureController = signatureControllers[fieldId]!;

    return SignatureFieldVertical(
      isRequired: isRequired,
      isActive: isActive,
      label: fieldName,
      signatureController: signatureController,
      signaturePath: formValues[fieldId],
      onSignatureSaved: (signature) {
        onValueChanged(fieldId, signature);
      },
    );
  }

  Widget buildPhotoField(
    String fieldName,
    String fieldId,
    bool isActive,
    bool isRequired,
    Map<String, dynamic> formValues,
    Function(String, dynamic) onValueChanged,
  ) {
    return PhotoFieldVertical(
      isRequired: isRequired,
      isActive: isActive,
      label: fieldName,
      value: formValues[fieldId],
      onImagePicked: (imagePath) => onValueChanged(fieldId, imagePath),
    );
  }

  Widget buildSwitchField(
    String fieldName,
    String fieldId,
    bool isActive,
    bool isRequired,
    Map<String, dynamic> formValues,
    Function(String, dynamic) onValueChanged,
  ) {
    formValues[fieldId] ??= false;
    return SwitchFieldVertical(
      isRequired: isRequired,
      isActive: isActive,
      label: fieldName,
      value: formValues[fieldId],
      onChanged: (value) => onValueChanged(fieldId, value),
    );
  }

  Widget buildPickListField(
    String fieldName,
    String fieldId,
    bool isActive,
    bool isRequired,
    Map<String, dynamic> formValues,
    Function(String, dynamic) onValueChanged,
    PickList? pickList,
  ) {
    return PickListFieldVertical<String>(
      label: fieldName,
      value: formValues[fieldId],
      items: pickList?.options.map((item) => item.id).toList() ?? [],
      itemAsString:
          (String? id) =>
              pickList?.options.firstWhere((option) => option.id == id).name ??
              "",
      onChanged: (value) => onValueChanged(fieldId, value),
      isRequired: isRequired,
    );
  }
}
