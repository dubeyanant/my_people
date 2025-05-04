import 'package:flutter/material.dart';

import 'dart:math' as math;

class ThinkingIndicator extends StatefulWidget {
  /// Creates a thinking indicator widget with customizable properties
  const ThinkingIndicator({
    super.key,
    this.dotCount = 3,
    this.dotSize = 8.0,
    this.dotSpacing = 4.0,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.primaryColor,
    this.secondaryColor,
    this.showLabel = false,
    this.label = "Thinking",
  });

  /// Number of dots in the animation
  final int dotCount;

  /// Size of each dot in pixels
  final double dotSize;

  /// Spacing between dots in pixels
  final double dotSpacing;

  /// Duration for one complete animation cycle
  final Duration animationDuration;

  /// Primary color for the dots (uses theme color if null)
  final Color? primaryColor;

  /// Secondary color for the dots (uses theme color if null)
  final Color? secondaryColor;

  /// Whether to show a text label
  final bool showLabel;

  /// Text to display if showLabel is true
  final String label;

  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _colorController;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();

    // Controller for bounce animations
    _bounceController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();

    // Controller for color transitions
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Create staggered animations for each dot
    _createAnimations();
  }

  void _createAnimations() {
    _bounceAnimations = List.generate(widget.dotCount, (index) {
      // Stagger the animations with different start and end times
      final double startValue = index * (1 / widget.dotCount);
      final double endValue = startValue + 0.5;

      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutQuad)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInQuad)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _bounceController,
          curve: Interval(
            startValue,
            endValue > 1.0 ? 1.0 : endValue,
            curve: Curves.linear,
          ),
        ),
      );
    });
  }

  @override
  void didUpdateWidget(ThinkingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recreate animations if dot count changes
    if (oldWidget.dotCount != widget.dotCount) {
      _createAnimations();
    }

    // Update animation duration if it changes
    if (oldWidget.animationDuration != widget.animationDuration) {
      _bounceController.duration = widget.animationDuration;
      _bounceController
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Widget _buildDot(BuildContext context, int index) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        // Calculate dot scale and offset for bounce effect
        final double scale = 0.5 + (_bounceAnimations[index].value * 0.5);
        final double yOffset =
            -_bounceAnimations[index].value * widget.dotSize * 0.8;

        // Get colors from theme or custom props
        final Color primaryColor =
            widget.primaryColor ?? Theme.of(context).colorScheme.primary;
        final Color secondaryColor =
            widget.secondaryColor ?? Theme.of(context).colorScheme.secondary;

        // Animate color based on a sine wave for smooth transition
        final Color dotColor = Color.lerp(
          primaryColor,
          secondaryColor,
          (math.sin(_colorController.value * math.pi * 2 + index) + 1) / 2,
        )!;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.dotSize,
              height: widget.dotSize,
              margin: EdgeInsets.symmetric(horizontal: widget.dotSpacing / 2),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withAlpha(77),
                    blurRadius: widget.dotSize * 0.8,
                    spreadRadius: widget.dotSize * 0.2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.dotCount,
                (index) => _buildDot(context, index),
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
