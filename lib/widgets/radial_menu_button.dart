import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/utility/shared_preferences.dart';

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

class RadialMenuButton extends StatefulWidget {
  final List<RadialMenuOption> options;

  const RadialMenuButton({
    super.key,
    required this.options,
  });

  @override
  State<RadialMenuButton> createState() => _RadialMenuButtonState();
}

class _RadialMenuButtonState extends State<RadialMenuButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chargeController;
  ScrollController? _scrollController;

  bool _isMenuOpen = false;
  Timer? _longPressTimer;
  Timer? _hapticTimer;
  int _hapticTickCount = 0;

  // Gesture tracking
  Offset? _pressOrigin;
  bool _isSwiping = false;
  int _highlightedIndex = -1;

  // Scroll hide/show tracking
  double _lastScrollOffset = 0.0;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _chargeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollListener();
  }

  void _attachScrollListener() {
    if (_scrollController != null) {
      _scrollController!.removeListener(_onScroll);
    }
    _scrollController = PrimaryScrollController.maybeOf(context);
    if (_scrollController != null) {
      _scrollController!.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    final offset = _scrollController!.offset;

    // Ignore bounces at the top
    if (offset < 0) return;

    if (offset > _lastScrollOffset && offset > 20) {
      if (_isVisible) {
        setState(() => _isVisible = false);
      }
    } else if (offset < _lastScrollOffset) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
      }
    }
    _lastScrollOffset = offset;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _hapticTimer?.cancel();
    _animationController.dispose();
    _chargeController.dispose();
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _startHapticEscalation() {
    _hapticTickCount = 0;
    _hapticTimer?.cancel();
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
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

  void _stopHapticEscalation() {
    _hapticTimer?.cancel();
    _hapticTimer = null;
    _hapticTickCount = 0;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pressOrigin = event.localPosition;
    _isSwiping = false;
    _highlightedIndex = -1;

    // Start the charge ring animation immediately
    _chargeController.forward(from: 0.0);

    // Start escalating haptic feedback
    _startHapticEscalation();

    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_isSwiping) {
        // Menu is opening — stop haptic escalation and give a definitive click
        _stopHapticEscalation();
        HapticFeedback.lightImpact();
        setState(() {
          _isMenuOpen = true;
          _animationController.forward(from: 0.0);
        });
        // Fade out the charge ring once menu opens
        _chargeController.reverse();

        // Track long-press count for swipe pro-tip
        _trackLongPressForTip();
      }
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_pressOrigin == null) return;

    final diff = event.localPosition - _pressOrigin!;

    // Check if we passed the swipe threshold before the timer pops
    if (!_isMenuOpen && diff.distance > 35) {
      _longPressTimer?.cancel();
      if (!_isSwiping) {
        _isSwiping = true;
        // Cancel charge animation and haptics on swipe
        _chargeController.stop();
        _chargeController.value = 0.0;
        _stopHapticEscalation();
        HapticFeedback.lightImpact();
      }
    }

    if (_isSwiping || _isMenuOpen) {
      _updateHighlightedOption(diff);
      setState(() {});
    }
  }

  void _updateHighlightedOption(Offset diff) {
    if (diff.distance < 35) {
      if (_highlightedIndex != -1) {
        _highlightedIndex = -1;
        HapticFeedback.selectionClick();
      }
      return;
    }
    // Calculate angle in degrees from x-axis (right = 0, straight up = 90)
    // In Flutter screen coordinates, -dy is UP.
    final rad = math.atan2(-diff.dy, diff.dx);
    double deg = rad * 180 / math.pi;
    if (deg < 0) {
      deg += 360;
    }

    // Find nearest option
    double minDiff = double.infinity;
    int nearestIdx = -1;
    for (int i = 0; i < widget.options.length; i++) {
      if (!widget.options[i].enabled) continue; // Skip disabled options

      final optDeg = widget.options[i].degrees;
      // circular difference
      double angleDiff = (deg - optDeg).abs();
      if (angleDiff > 180) angleDiff = 360 - angleDiff;

      if (angleDiff < minDiff) {
        minDiff = angleDiff;
        nearestIdx = i;
      }
    }

    // Only highlight if within a reasonable angle cone (e.g. +/- 45 degrees)
    if (minDiff <= 45) {
      if (_highlightedIndex != nearestIdx) {
        _highlightedIndex = nearestIdx;
        HapticFeedback.selectionClick();
      }
    } else {
      if (_highlightedIndex != -1) {
        _highlightedIndex = -1;
        HapticFeedback.selectionClick();
      }
    }
  }

  bool _shouldShowTip = false;

  void _handlePointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    _stopHapticEscalation();

    if (_highlightedIndex != -1 && widget.options[_highlightedIndex].enabled) {
      HapticFeedback.mediumImpact();
      AnalyticsHelper.trackFeatureUsage(
          'radial_button_${widget.options[_highlightedIndex].label}');
      widget.options[_highlightedIndex].onSelected();
    }
    _closeMenu();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _stopHapticEscalation();
    _closeMenu();
  }

  void _trackLongPressForTip() {
    if (SharedPrefs.getSwipeTipShown()) return;
    SharedPrefs.incrementRadialLongPressCount();
    if (SharedPrefs.getRadialLongPressCount() >= 3) {
      _shouldShowTip = true;
    }
  }

  void _showSwipeTip() {
    SharedPrefs.setSwipeTipShown(true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(60),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Pro Tip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe directly towards an option\nto skip the menu!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _closeMenu() {
    _animationController.reverse();
    // Snap the charge ring back quickly
    if (_chargeController.isAnimating || _chargeController.value > 0) {
      _chargeController.animateTo(0.0,
          duration: const Duration(milliseconds: 150), curve: Curves.easeIn);
    }
    setState(() {
      _isMenuOpen = false;
      _isSwiping = false;
      _pressOrigin = null;
      _highlightedIndex = -1;
    });

    // Show swipe pro-tip after the menu close animation finishes
    if (_shouldShowTip) {
      _shouldShowTip = false;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _showSwipeTip();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _isVisible ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutSine,
      child: SizedBox(
        width: 300,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Menu Options
            for (int i = 0; i < widget.options.length; i++) _buildOptionNode(i),

            // Main Button
            Listener(
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              onPointerCancel: _handlePointerCancel,
              child: GestureDetector(
                onTap: () {}, // absorbs taps
                onPanStart: (_) {}, // absorbs drags
                child: _buildMainButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionNode(int index) {
    final option = widget.options[index];
    final isHighlighted = index == _highlightedIndex;
    final isEnabled = option.enabled;

    // Stagger animation based on index
    final startVal = (index * 0.1).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Interval(startVal, 1.0, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        if (curve.value == 0) return const SizedBox.shrink();

        // Convert degrees to radians for positioning (remember -y is UP)
        final rad = option.degrees * math.pi / 180;
        final radius = 110 * curve.value; // distance from center
        final dx = radius * math.cos(rad);
        final dy = -radius * math.sin(rad);

        final nodeScale = isHighlighted ? 1.15 : 1.0;
        final nodeOpacity = isHighlighted
            ? 1.0
            : (_isSwiping && _highlightedIndex != -1 ? 0.6 : 1.0);
        final clampedOpacity = (curve.value * nodeOpacity).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: curve.value * nodeScale,
            child: Opacity(
              opacity: clampedOpacity,
              child: child,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? Theme.of(context).colorScheme.primary.withAlpha(50)
                      : Theme.of(context).colorScheme.surface.withAlpha(50),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(isEnabled ? 102 : 30),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  option.icon,
                  color: isHighlighted
                      ? Theme.of(context).colorScheme.primary
                      : (isEnabled
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(100)),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            option.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isEnabled
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return SizedBox(
      width: 80,
      height: 80,
      child: AnimatedBuilder(
        animation: _chargeController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ChargeRingPainter(
              progress: _chargeController.value,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(child: child),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(76),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: AnimatedRotation(
                    turns: _isMenuOpen ? 0.125 : 0.0, // Slight spin
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(179),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints an expanding circular ring around the button during the charge-up phase.
class _ChargeRingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;

  _ChargeRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // The ring expands from slightly outside the 64px button (radius 32)
    // to the edge of our 80px bounding box (radius 40).
    final baseRadius = 34.0;
    final maxExpand = 8.0;
    final radius = baseRadius + (maxExpand * progress);

    // Stroke width grows slightly as it charges
    final strokeWidth = 2.0 + (1.5 * progress);

    // Opacity ramps up then holds, using a gentle ease curve
    final opacity = (progress * 1.2).clamp(0.0, 0.8);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw a sweep arc proportional to progress (full circle at 1.0)
    final sweepAngle = 2 * math.pi * progress;
    // Start from top (-π/2)
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Add a subtle glow effect behind the arc
    if (progress > 0.2) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChargeRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
