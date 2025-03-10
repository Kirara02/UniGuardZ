import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class ImageSourceDialog extends StatelessWidget {
  final Function(ImageSource) onImageSourceSelected;

  const ImageSourceDialog({
    super.key,
    required this.onImageSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              onImageSourceSelected(ImageSource.camera);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.images.camera.image(
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  color: context.colorScheme.onSurface,
                ),
                const Text("Camera"),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              onImageSourceSelected(ImageSource.gallery);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.images.gallery.image(
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  color: context.colorScheme.onSurface,
                ),
                const Text("Gallery"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
