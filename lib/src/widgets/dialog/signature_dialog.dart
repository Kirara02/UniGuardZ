import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class SignatureDialog<T> extends StatelessWidget {
  final String title;
  final SignatureController signatureController;
  final Function(T?) onSave;
  final Function onCancel;
  final Function onReset;

  const SignatureDialog({
    super.key,
    required this.title,
    required this.signatureController,
    required this.onSave,
    required this.onCancel,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium!.copyWith(
                    color: context.colorScheme.onSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    signatureController.clear();
                    onReset(); // Memastikan tanda tangan dihapus dari UI utama
                    Navigator.of(context).pop();
                  },
                  label: const Text("Reset"),
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 200,
                child: Signature(
                  controller: signatureController,
                  backgroundColor: context.colorScheme.surfaceContainerHigh,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      onCancel();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (signatureController.isNotEmpty) {
                        final signature =
                            await signatureController.toPngBytes();
                        onSave(signature as T?);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
