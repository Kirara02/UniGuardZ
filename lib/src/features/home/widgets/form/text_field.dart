import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class CustomTextFieldVertical extends StatelessWidget {
  final String label;
  final String? value;
  final Function(String) onChanged;
  final bool isRequired;
  final bool isActive;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

  const CustomTextFieldVertical({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isRequired = false,
    this.isActive = false,
    this.maxLines,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    final bool isMultiline = keyboardType == TextInputType.multiline;
    final int? effectiveMaxLines = isMultiline ? (maxLines ?? 4) : 1;
    final TextInputAction effectiveTextInputAction =
        isMultiline ? TextInputAction.newline : textInputAction;

    return Visibility(
      visible: isActive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (isRequired)
                  const TextSpan(
                    text: "* ",
                    style: TextStyle(color: Colors.red),
                  ),
                TextSpan(
                  text: label,
                  style: textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            softWrap: true,
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            constraints: BoxConstraints(
              minHeight: isMultiline ? 64 : 48, // Set specific heights
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: TextFormField(
              initialValue: value?.toString(),
              onChanged: (val) => onChanged(val),
              maxLines: effectiveMaxLines,
              minLines: isMultiline ? 4 : 1,
              textInputAction: effectiveTextInputAction,
              keyboardType: keyboardType,
              style: textTheme.labelSmall,
              cursorColor: colorScheme.onSurface,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: InputBorder.none,
                hintText: "Type here ...",
                hintStyle: textTheme.bodySmall!.copyWith(
                  color: colorScheme.tertiary,
                ),
              ),
              validator: (val) {
                if (isRequired && (val == null || val.isEmpty)) {
                  return 'Field $label is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
