import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/widgets/radial_menu/radial_menu_button.dart';
import 'package:my_people/widgets/radial_menu/radial_menu_haptics.dart';
import 'package:my_people/widgets/radial_menu/swipe_tip_helper.dart';

/// Mixin that encapsulates all pointer/gesture logic for the radial menu.
///
/// Manages long-press detection, instant-swipe recognition, option highlighting,
/// and orchestrates feedback via [RadialMenuHaptics].
mixin RadialMenuGestureHandler on State<RadialMenuButton>, RadialMenuHaptics {
  // ── Constants ──────────────────────────────────────────────────────────

  static const double swipeThreshold = 35.0;
  static const double angleCone = 45.0;
  static const Duration longPressDuration = Duration(milliseconds: 150);

  // ── State ──────────────────────────────────────────────────────────────

  late AnimationController menuAnimationController;
  Timer? _longPressTimer;

  Offset? pressOrigin;
  bool isSwiping = false;
  bool isMenuOpen = false;
  int highlightedIndex = -1;
  bool _shouldShowTip = false;

  void initMenuAnimationController(TickerProvider vsync) {
    menuAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 250),
    );
  }

  // ── Pointer handlers ───────────────────────────────────────────────────

  void handlePointerDown(PointerDownEvent event) {
    pressOrigin = event.localPosition;
    isSwiping = false;
    highlightedIndex = -1;

    // Start charge ring + haptic escalation
    startCharge();
    startHapticEscalation();

    _longPressTimer?.cancel();
    _longPressTimer = Timer(longPressDuration, () {
      if (!isSwiping) {
        stopHapticEscalation();
        HapticFeedback.lightImpact();
        setState(() {
          isMenuOpen = true;
          menuAnimationController.forward(from: 0.0);
        });
        reverseCharge();

        // Track for swipe pro-tip
        if (SwipeTipHelper.trackAndCheck()) {
          _shouldShowTip = true;
        }
      }
    });
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (pressOrigin == null) return;

    final diff = event.localPosition - pressOrigin!;

    // Instant-swipe detection before the long-press timer fires
    if (!isMenuOpen && diff.distance > swipeThreshold) {
      _longPressTimer?.cancel();
      if (!isSwiping) {
        isSwiping = true;
        cancelAllFeedback();
        HapticFeedback.lightImpact();
      }
    }

    if (isSwiping || isMenuOpen) {
      _updateHighlightedOption(diff);
      setState(() {});
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    stopHapticEscalation();

    if (highlightedIndex != -1 && widget.options[highlightedIndex].enabled) {
      HapticFeedback.mediumImpact();
      AnalyticsHelper.trackFeatureUsage(
          'radial_button_${widget.options[highlightedIndex].label}');
      widget.options[highlightedIndex].onSelected();
    }
    closeMenu();
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    stopHapticEscalation();
    closeMenu();
  }

  // ── Menu close ─────────────────────────────────────────────────────────

  void closeMenu() {
    menuAnimationController.reverse();
    snapChargeBack();
    setState(() {
      isMenuOpen = false;
      isSwiping = false;
      pressOrigin = null;
      highlightedIndex = -1;
    });

    // Show swipe pro-tip after the menu close animation finishes
    if (_shouldShowTip) {
      _shouldShowTip = false;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) SwipeTipHelper.show(context);
      });
    }
  }

  // ── Angle math ─────────────────────────────────────────────────────────

  void _updateHighlightedOption(Offset diff) {
    if (diff.distance < swipeThreshold) {
      if (highlightedIndex != -1) {
        highlightedIndex = -1;
        HapticFeedback.selectionClick();
      }
      return;
    }

    // Calculate angle in degrees (right = 0°, up = 90°)
    final rad = math.atan2(-diff.dy, diff.dx);
    double deg = rad * 180 / math.pi;
    if (deg < 0) deg += 360;

    // Find nearest enabled option
    double minDiff = double.infinity;
    int nearestIdx = -1;
    for (int i = 0; i < widget.options.length; i++) {
      if (!widget.options[i].enabled) continue;
      final optDeg = widget.options[i].degrees;
      double angleDiff = (deg - optDeg).abs();
      if (angleDiff > 180) angleDiff = 360 - angleDiff;
      if (angleDiff < minDiff) {
        minDiff = angleDiff;
        nearestIdx = i;
      }
    }

    if (minDiff <= angleCone) {
      if (highlightedIndex != nearestIdx) {
        highlightedIndex = nearestIdx;
        HapticFeedback.selectionClick();
      }
    } else {
      if (highlightedIndex != -1) {
        highlightedIndex = -1;
        HapticFeedback.selectionClick();
      }
    }
  }

  void disposeGestureHandler() {
    _longPressTimer?.cancel();
    menuAnimationController.dispose();
  }
}
