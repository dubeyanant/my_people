import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:my_people/widgets/radial_menu/charge_ring_painter.dart';
import 'package:my_people/widgets/radial_menu/radial_menu_gesture_handler.dart';
import 'package:my_people/widgets/radial_menu/radial_menu_haptics.dart';
import 'package:my_people/widgets/radial_menu/radial_menu_option.dart';

export 'package:my_people/widgets/radial_menu/radial_menu_option.dart';

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
    with TickerProviderStateMixin, RadialMenuHaptics, RadialMenuGestureHandler {
  ScrollController? _scrollController;

  // Scroll hide/show tracking
  double _lastScrollOffset = 0.0;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    initChargeController(this);
    initMenuAnimationController(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollListener();
  }

  @override
  void dispose() {
    disposeHaptics();
    disposeGestureHandler();
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  // ── Scroll-to-hide ─────────────────────────────────────────────────────

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
      if (_isVisible) setState(() => _isVisible = false);
    } else if (offset < _lastScrollOffset) {
      if (!_isVisible) setState(() => _isVisible = true);
    }
    _lastScrollOffset = offset;
  }

  // ── Build ──────────────────────────────────────────────────────────────

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
            for (int i = 0; i < widget.options.length; i++) _buildOptionNode(i),
            Listener(
              onPointerDown: handlePointerDown,
              onPointerMove: handlePointerMove,
              onPointerUp: handlePointerUp,
              onPointerCancel: handlePointerCancel,
              child: GestureDetector(
                onTap: () {},
                onPanStart: (_) {},
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
    final isHighlighted = index == highlightedIndex;
    final isEnabled = option.enabled;

    final startVal = (index * 0.1).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: menuAnimationController,
      curve: Interval(startVal, 1.0, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        if (curve.value == 0) return const SizedBox.shrink();

        final rad = option.degrees * math.pi / 180;
        final radius = 110 * curve.value;
        final dx = radius * math.cos(rad);
        final dy = -radius * math.sin(rad);

        final nodeScale = isHighlighted ? 1.15 : 1.0;
        final nodeOpacity = isHighlighted
            ? 1.0
            : (isSwiping && highlightedIndex != -1 ? 0.6 : 1.0);
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
        animation: chargeController,
        builder: (context, child) {
          return CustomPaint(
            painter: ChargeRingPainter(
              progress: chargeController.value,
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
                    turns: isMenuOpen ? 0.125 : 0.0,
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
