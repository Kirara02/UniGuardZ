import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class PickListFieldVertical<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final Function(T?) onChanged;
  final bool isRequired;
  final String Function(T)? itemAsString;
  final String? hintText;

  const PickListFieldVertical({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.itemAsString,
    this.hintText = "Select",
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Column(
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
        const SizedBox(height: 4),
        DropdownSearch<T>(
          popupProps: PopupProps.menu(
            menuProps: MenuProps(
              backgroundColor: colorScheme.surfaceContainer,
            ),
            showSearchBox: false,
            showSelectedItems: true,
            fit: FlexFit.loose,
            itemBuilder: (context, item, isDisabled, isSelected) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  itemAsString?.call(item) ?? item.toString(),
                  style: context.textTheme.titleSmall!.copyWith(
                    color: isSelected ? Colors.blue : colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
          items: (filter, infiniteScrollProps) => items,
          itemAsString: itemAsString ?? (item) => item.toString(),
          compareFn: (T? item, T? selectedItem) => item == selectedItem,
          onChanged: onChanged,
          selectedItem: value,
          decoratorProps: DropDownDecoratorProps(
            baseStyle: context.textTheme.labelMedium,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              hintText: hintText,
              hintStyle: textTheme.labelMedium,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (isRequired && value == null) {
              return 'Field $label is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
