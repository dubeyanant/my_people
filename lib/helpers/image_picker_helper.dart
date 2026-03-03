import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/utility/debug_print.dart';

/// Centralised helper for image picking, cropping, and related utilities.
///
/// Use [showImageSourceBottomSheet] to present the camera / gallery picker
/// sheet — both the add-person bottom sheet and the profile setup screen share
/// this UI.  Under the hood it calls [pickAndCropImage] for the full
/// pick → crop pipeline.
abstract final class ImagePickerHelper {
  // ---------------------------------------------------------------------------
  // Default profile-picture assets
  // ---------------------------------------------------------------------------

  static const List<String> defaultImages = [
    'assets/profile_pictures/default1.webp',
    'assets/profile_pictures/default2.webp',
    'assets/profile_pictures/default3.webp',
    'assets/profile_pictures/default4.webp',
    'assets/profile_pictures/default5.webp',
    'assets/profile_pictures/default6.webp',
    'assets/profile_pictures/default7.webp',
    'assets/profile_pictures/default8.webp',
  ];

  /// Returns a random image path from [defaultImages].
  static String randomDefaultImage() {
    return defaultImages[Random().nextInt(defaultImages.length)];
  }

  // ---------------------------------------------------------------------------
  // Asset-path check
  // ---------------------------------------------------------------------------

  /// Returns `true` when [path] begins with `assets/` (i.e. it is a bundled
  /// asset rather than a file-system path).
  static bool isAssetPath(String path) {
    return path.startsWith('assets/');
  }

  // ---------------------------------------------------------------------------
  // Image picking
  // ---------------------------------------------------------------------------

  /// Picks an image from [source], runs it through the crop UI, and returns
  /// the resulting [File].  Returns `null` if the user cancels at any step.
  ///
  /// Tracks the action with [AnalyticsHelper].
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    AnalyticsHelper.trackFeatureUsage(
      source == ImageSource.camera ? 'pick_image_camera' : 'pick_image_gallery',
    );

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxHeight: 720,
      maxWidth: 720,
    );

    if (pickedFile == null) return null;

    if (context.mounted) {
      return _cropImage(context: context, sourcePath: pickedFile.path);
    }

    return File(pickedFile.path);
  }

  /// Shows a modal bottom sheet that lets the user choose between their
  /// **camera** and their **gallery**.
  ///
  /// After the user picks a source, [pickAndCropImage] is called and the
  /// resulting [File] (or `null` on cancellation) is passed to [onImagePicked].
  static void showImageSourceBottomSheet({
    required BuildContext context,
    required void Function(File? file) onImagePicked,
  }) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickAndCropImage(
                  context: context,
                  source: ImageSource.gallery,
                );
                onImagePicked(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_rear_outlined),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickAndCropImage(
                  context: context,
                  source: ImageSource.camera,
                );
                onImagePicked(file);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static Future<File> _cropImage({
    required BuildContext context,
    required String sourcePath,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 75,
        maxWidth: 720,
        maxHeight: 720,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: true,
            aspectRatioPickerButtonHidden: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      return croppedFile != null ? File(croppedFile.path) : File(sourcePath);
    } catch (e) {
      DebugPrint.log(e.toString(), color: DebugColor.red);
      return File(sourcePath);
    }
  }
}
