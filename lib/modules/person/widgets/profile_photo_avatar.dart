import 'dart:io';

import 'package:flutter/material.dart';

/// A circular profile photo that shows an edit-badge overlay in the
/// bottom-right corner.  Tapping anywhere on the widget calls [onTap].
///
/// If [selectedImage] is non-null it is shown; otherwise [fallbackAsset] (an
/// asset path) is used.
class ProfilePhotoAvatar extends StatelessWidget {
  const ProfilePhotoAvatar({
    super.key,
    required this.selectedImage,
    required this.fallbackAsset,
    required this.onTap,
    this.radius = 40,
  });

  final File? selectedImage;
  final String fallbackAsset;
  final VoidCallback onTap;

  /// Radius of the [CircleAvatar].  The edit-badge scales proportionally.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final badgeRadius = radius * 0.3;
    final badgeIconSize = badgeRadius * 0.8;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: selectedImage != null
                ? FileImage(selectedImage!)
                : AssetImage(fallbackAsset) as ImageProvider,
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: CircleAvatar(
              radius: badgeRadius,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.edit,
                size: badgeIconSize,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
