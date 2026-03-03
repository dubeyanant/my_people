import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_people/widgets/radial_menu/radial_menu_button.dart';

/// Mixin that manages the charge-ring animation and escalating haptic feedback.
///
/// Requires the host state to use [TickerProviderStateMixin] and
/// provide access to [chargeController].
mixin RadialMenuHaptics on State<RadialMenuButton> {
  late final AnimationController chargeController;

  Timer? _hapticTimer;
  int _hapticTickCount = 0;

  // ── Haptic escalation ──────────────────────────────────────────────────

  static const _hapticInterval = Duration(milliseconds: 80);

  /// Starts a periodic haptic timer that escalates intensity over time:
  /// light → medium → heavy.
  void startHapticEscalation() {
    _hapticTickCount = 0;
    _hapticTimer?.cancel();
    _hapticTimer = Timer.periodic(_hapticInterval, (_) {
      _hapticTickCount++;
      if (_hapticTickCount <= 3) {
        HapticFeedback.lightImpact();
      } else if (_hapticTickCount <= 6) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  /// Stops all haptic feedback and resets the tick counter.
  void stopHapticEscalation() {
    _hapticTimer?.cancel();
    _hapticTimer = null;
    _hapticTickCount = 0;
  }

  // ── Charge ring ────────────────────────────────────────────────────────

  static const chargeDuration = Duration(milliseconds: 600);
  static const chargeReverseDuration = Duration(milliseconds: 150);

  void initChargeController(TickerProvider vsync) {
    chargeController = AnimationController(
      vsync: vsync,
      duration: chargeDuration,
    );
  }

  /// Starts the charge ring expanding animation.
  void startCharge() => chargeController.forward(from: 0.0);

  /// Reverses the charge ring animation (e.g. when the menu opens).
  void reverseCharge() => chargeController.reverse();

  /// Immediately cancels the charge ring (e.g. on swipe).
  void cancelCharge() {
    chargeController.stop();
    chargeController.value = 0.0;
  }

  /// Smoothly snaps the charge ring back to zero.
  void snapChargeBack() {
    if (chargeController.isAnimating || chargeController.value > 0) {
      chargeController.animateTo(
        0.0,
        duration: chargeReverseDuration,
        curve: Curves.easeIn,
      );
    }
  }

  // ── Combined cancellation ──────────────────────────────────────────────

  /// Cancels both haptic and charge feedback instantly (e.g. on swipe).
  void cancelAllFeedback() {
    cancelCharge();
    stopHapticEscalation();
  }

  void disposeHaptics() {
    _hapticTimer?.cancel();
    chargeController.dispose();
  }
}
