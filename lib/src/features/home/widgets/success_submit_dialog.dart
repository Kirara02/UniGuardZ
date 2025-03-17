import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

void showSuccessDialog(
  BuildContext context,
  WidgetRef ref, {
  required String formType,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(context.l10n!.form_success_title(formType)),
          content: Text(context.l10n!.form_success_message(formType)),
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.of(context).pop();
                HomeRoute().go(context);
              },
              child: Text(context.l10n!.ok),
            ),
          ],
        ),
  );
}
