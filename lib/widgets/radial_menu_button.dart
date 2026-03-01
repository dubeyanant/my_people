import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RadialMenuOption {
  final String label;
  final IconData icon;
  final double degrees; // 90 = straight up, 0 = right, 180 = left
  final VoidCallback onSelected;

  const RadialMenuOption({
    required this.label,
    required this.icon,
    required this.degrees,
    required this.onSelected,
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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ScrollController? _scrollController;

  bool _isMenuOpen = false;
  Timer? _longPressTimer;

  // Gesture tracking
  Offset? _pressOrigin;
  bool _isSwiping = false;
  int _highlightedIndex = -1;

  // Glass specs
  final double _baseBlur = 12.0;
  final double _baseOpacity = 0.15;
  double _currentBlur = 12.0;
  double _currentOpacity = 0.15;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
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
    setState(() {
      // If we scroll past top, increase blur and lower opacity
      if (offset > 10) {
        _currentBlur = 18.0;
        _currentOpacity = 0.08;
      } else {
        _currentBlur = _baseBlur;
        _currentOpacity = _baseOpacity;
      }
    });
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _animationController.dispose();
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pressOrigin = event.localPosition;
    _isSwiping = false;
    _highlightedIndex = -1;

    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_isSwiping) {
        HapticFeedback.lightImpact();
        setState(() {
          _isMenuOpen = true;
          _animationController.forward(from: 0.0);
        });
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

  void _handlePointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    if (_highlightedIndex != -1) {
      HapticFeedback.mediumImpact();
      widget.options[_highlightedIndex].onSelected();
    }
    _closeMenu();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _closeMenu();
  }

  void _closeMenu() {
    _animationController.reverse();
    setState(() {
      _isMenuOpen = false;
      _isSwiping = false;
      _pressOrigin = null;
      _highlightedIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 150,
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
    );
  }

  Widget _buildOptionNode(int index) {
    final option = widget.options[index];
    final isHighlighted = index == _highlightedIndex;

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
        final radius = 110.0 * curve.value; // distance from center
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
                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(102),
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
                      : Theme.of(context).colorScheme.onSurface,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.transparent, // background handled by container inside
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
          filter: ImageFilter.blur(
            sigmaX: _currentBlur,
            sigmaY: _currentBlur,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _currentOpacity),
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
                  Icons
                      .grid_view_rounded, // "small dot cluster or a soft grid icon"
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
