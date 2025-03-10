import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/utils/misc/image_picker_helper.dart';
import 'package:ugz_app/src/widgets/dialog/image_source_dialog.dart';

class PhotoFieldVertical extends StatefulWidget {
  final String label;
  final String? value;
  final Function(String?) onImagePicked;
  final bool isRequired;
  final bool isActive;

  const PhotoFieldVertical({
    super.key,
    required this.label,
    this.value,
    required this.onImagePicked,
    this.isRequired = false,
    this.isActive = false,
  });

  @override
  State<PhotoFieldVertical> createState() => _PhotoFieldVerticalState();
}

class _PhotoFieldVerticalState extends State<PhotoFieldVertical> {
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    if (source == ImageSource.camera) {
      PermissionStatus status = await Permission.camera.request();

      if (status.isDenied) {
        _showSettingsDialog(context);
        return;
      }
    }
    final pickedFile = await _imagePickerHelper.pickAndProcessImage(source);

    if (pickedFile != null) {
      widget.onImagePicked(pickedFile.path);
    } else {
      widget.onImagePicked(null); // No image picked or process failed
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "Camera permission is permanently denied. Please enable it from settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings(); // Buka pengaturan aplikasi
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ImageSourceDialog(
          onImageSourceSelected: (ImageSource source) {
            _pickImage(context, source); // Pilih gambar berdasarkan sumber
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Visibility(
      visible: widget.isActive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (widget.isRequired)
                  const TextSpan(
                    text: "* ",
                    style: TextStyle(color: Colors.red),
                  ),
                TextSpan(
                  text: widget.label,
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
              children: [
                InkWell(
                  onTap: () => _showImageSourceDialog(context),
                  child: widget.value != null
                      ? Container(
                          height: 68,
                          width: 80,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(widget.value!),
                              fit: BoxFit.cover,
                            ),
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
                          "Upload / Take Image",
                          style: textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "Max file size: 5MB", // Ubah sesuai kebutuhan Anda
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
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:ugz_app/src/constants/gen/assets.gen.dart';
// import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
// import 'package:ugz_app/src/constants/colors.dart';
// import 'package:ugz_app/src/utils/misc/image_picker_helper.dart';
// import 'package:ugz_app/src/widgets/dialog/source_image_dialog.dart';

// class PhotoFieldVertical extends StatefulWidget {
//   final String label;
//   final String? value;
//   final Function(String?) onImagePicked;
//   final bool isRequired;

//   const PhotoFieldVertical({
//     super.key,
//     required this.label,
//     this.value,
//     required this.onImagePicked,
//     this.isRequired = false,
//   });

//   @override
//   State<PhotoFieldVertical> createState() => _PhotoFieldVerticalState();
// }

// class _PhotoFieldVerticalState extends State<PhotoFieldVertical> {
//   final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();

//   /// **🔹 Fungsi untuk meminta izin kamera & galeri**
//   Future<bool> _requestPermissions(ImageSource source) async {
//     if (source == ImageSource.camera) {
//       var status = await Permission.camera.request();
//       if (status.isGranted) {
//         return true;
//       } else if (status.isPermanentlyDenied) {
//         _showPermissionDialog("Camera");
//         return false;
//       }
//     } else if (source == ImageSource.gallery) {
//       var status = await Permission.photos.request();
//       if (status.isGranted) {
//         return true;
//       } else if (status.isPermanentlyDenied) {
//         _showPermissionDialog("Gallery");
//         return false;
//       }
//     }
//     return false;
//   }

//   /// **🔹 Menampilkan Dialog jika izin ditolak permanen**
//   void _showPermissionDialog(String permissionType) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("$permissionType Permission"),
//         content: Text(
//             "To use this feature, allow access to $permissionType in Settings."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               openAppSettings();
//               Navigator.pop(context);
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }

//   /// **🔹 Memilih gambar dengan izin yang sudah dicek**
//   Future<void> _pickImage(BuildContext context, ImageSource source) async {
//     bool hasPermission = await _requestPermissions(source);
//     if (!hasPermission) return;

//     final pickedFile = await _imagePickerHelper.pickAndProcessImage(source);
//     if (pickedFile != null) {
//       widget.onImagePicked(pickedFile.path);
//     } else {
//       widget.onImagePicked(null);
//     }
//   }

//   void _showImageSourceDialog(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return ImageSourceDialog(
//           onImageSourceSelected: (ImageSource source) {
//             _pickImage(context, source); // Pilih gambar berdasarkan sumber
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = context.textTheme;
//     final colorScheme = context.colorScheme;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text.rich(
//           TextSpan(
//             children: [
//               if (widget.isRequired)
//                 const TextSpan(
//                   text: "* ",
//                   style: TextStyle(color: Colors.red),
//                 ),
//               TextSpan(
//                 text: widget.label,
//                 style: textTheme.labelMedium!.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           softWrap: true,
//         ),
//         const Gap(8),
//         Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: colorScheme.surface,
//           ),
//           child: Row(
//             children: [
//               InkWell(
//                 onTap: () => _showImageSourceDialog(context),
//                 child: widget.value != null
//                     ? Container(
//                         height: 68,
//                         width: 80,
//                         decoration: const BoxDecoration(
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(16),
//                             bottomLeft: Radius.circular(16),
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.file(
//                             File(widget.value!),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       )
//                     : Container(
//                         padding: const EdgeInsets.all(16),
//                         height: 68,
//                         width: 80,
//                         decoration: BoxDecoration(
//                           color: AppColors.secondaryExtraSoft,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(16),
//                             bottomLeft: Radius.circular(16),
//                           ),
//                         ),
//                         child: Assets.images.addImage.image(
//                           width: 32,
//                           height: 32,
//                           color: AppColors.secondary,
//                         ),
//                       ),
//               ),
//               // Expanded bagian untuk teks atau konten lainnya
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Upload / Take Image",
//                         style: textTheme.labelLarge!.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const Gap(4),
//                       Text(
//                         "Max file size: 5MB", // Ubah sesuai kebutuhan Anda
//                         style: textTheme.bodySmall!.copyWith(
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
