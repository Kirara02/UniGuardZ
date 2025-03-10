import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/widgets/dialog/signature_dialog.dart';

class SignatureFieldVertical extends StatelessWidget {
  final String label;
  final SignatureController signatureController;
  final bool isRequired;
  final bool isActive;
  final Function(String?) onSignatureSaved;
  final String? signaturePath;

  const SignatureFieldVertical({
    super.key,
    required this.label,
    required this.signatureController,
    this.isRequired = false,
    this.isActive = false,
    required this.onSignatureSaved,
    this.signaturePath,
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
                  ),
                ),
              ],
            ),
            softWrap: true,
          ),
          const Gap(8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _showSignatureDialog(context),
                  child: signaturePath != null
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          height: 68,
                          width: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Image.file(
                            File(signaturePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16),
                          height: 68,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Assets.images.addImage.image(
                            width: 32,
                            height: 32,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                // Expanded bagian untuk teks atau konten lainnya
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Insert your signature",
                          style: textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "This will be saved as your digital signature",
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _saveSignatureToCache(Uint8List signatureData) async {
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(signatureData);
    return filePath;
  }

  void _showSignatureDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Signature Dialog",
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation1, animation2, child) {
        final curvedAnimation =
            CurvedAnimation(parent: animation1, curve: Curves.easeInOut);

        return ScaleTransition(
          scale: curvedAnimation,
          child: SignatureDialog<Uint8List>(
            title: "Signature",
            signatureController: signatureController,
            onSave: (signature) async {
              if (signature != null) {
                final path = await _saveSignatureToCache(signature);
                onSignatureSaved(path);
              }
            },
            onReset: () {
              signatureController.clear();
              onSignatureSaved(null); // Hapus tanda tangan dari UI utama
            },
            onCancel: () {
              // onSignatureSaved(null);
            },
          ),
        );
      },
    );
    // .then((_) {
    //   if (signatureController.isEmpty) {
    //     signatureController.clear();
    //     onSignatureSaved(null);
    //   }
    // });
  }
}
