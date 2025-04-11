import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/constants/colors.dart';

class ListItem extends ConsumerWidget {
  final VoidCallback onPressed;
  final String? prefixIconPath;
  final String title;
  final String? subtitle;
  final ListItemType? type;
  final Widget? suffix;
  final Widget? prefix;

  const ListItem({
    super.key,
    required this.title,
    required this.onPressed,
    this.type = ListItemType.svg,
    this.subtitle,
    this.suffix,
    this.prefix,
    this.prefixIconPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.outline.withValues(alpha: 0.4),
              spreadRadius: 0,
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.colorScheme.surfaceContainerHigh,
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.outlineVariant,
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildIcon(),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: context.textTheme.labelSmall!.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (suffix != null)
              suffix!
            else
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
                color: AppColors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (prefixIconPath != null && type != null) {
      switch (type!) {
        case ListItemType.svg:
          return SvgPicture.asset(prefixIconPath!, width: 20, height: 20);
        case ListItemType.png:
          return Image.asset(
            prefixIconPath!,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          );
      }
    } else if (prefix != null) {
      return prefix!;
    } else {
      return SizedBox();
    }
  }
}

enum ListItemType { svg, png }
