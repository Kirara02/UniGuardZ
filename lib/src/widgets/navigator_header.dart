import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class NavigatorHeader extends ConsumerWidget {
  final String title;
  const NavigatorHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () {},
          label: Text(
            title,
            style: context.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 18),
        ),
      ],
    );
  }
}
