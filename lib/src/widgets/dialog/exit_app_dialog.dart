import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

Future<bool> showExitDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.l10n!.confirm_exit_title),
            content: Text(context.l10n!.confirm_exit_message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.l10n!.yes),
              ),
            ],
          );
        },
      ) ??
      false;
}

void exitApp() {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else {
    exit(0);
  }
}
