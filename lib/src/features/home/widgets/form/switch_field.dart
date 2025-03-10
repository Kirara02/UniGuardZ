import 'package:flutter/material.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class SwitchFieldVertical extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final bool isRequired;
  final bool isActive;

  const SwitchFieldVertical({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isRequired = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

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
                    // color: const Color(0xff717171),
                  ),
                ),
              ],
            ),
            softWrap: true,
          ),
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val!),
            side: BorderSide(color: colorScheme.outline, width: 2),
          ),
        ],
      ),
    );
  }
}
