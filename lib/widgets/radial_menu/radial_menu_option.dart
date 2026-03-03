import 'package:flutter/material.dart';

/// Data model for a single option in the radial menu.
class RadialMenuOption {
  final String label;
  final IconData icon;
  final double degrees; // 90 = straight up, 0 = right, 180 = left
  final VoidCallback onSelected;
  final bool enabled;

  const RadialMenuOption({
    required this.label,
    required this.icon,
    required this.degrees,
    required this.onSelected,
    this.enabled = true,
  });
}
