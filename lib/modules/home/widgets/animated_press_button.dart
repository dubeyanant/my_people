import 'package:flutter/material.dart';

class AnimatedPressButton extends StatefulWidget {
  // The callback that is called when the button is tapped.
  final VoidCallback onPressed;
  // The widget below this widget in the tree. Typically a Text widget.
  final Widget child;
  // The background color of the button. Defaults to the theme's primary color.
  final Color? backgroundColor;
  // The color of the button when it is being pressed. Defaults to a slightly darker shade of the background color.
  final Color? foregroundColor;
  // The border radius of the button. Defaults to 12.0.
  final double borderRadius;
  // The padding inside the button. Defaults to EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0).
  final EdgeInsetsGeometry padding;
  // The elevation of the button, creating a shadow effect. Defaults to 4.0.
  final double elevation;

  const AnimatedPressButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 100.0,
    this.padding = const EdgeInsets.all(12),
    this.elevation = 4.0,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  // Animation controller for the scaling effect.
  late AnimationController _controller;
  // Animation for scaling down the button on press.
  late Animation<double> _scaleAnimation;

  // Flag to track if the button is currently pressed down.
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );

    // Define the scale animation (e.g., scale down to 95%).
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the animation controller when the widget is removed.
    _controller.dispose();
    super.dispose();
  }

  // Handles the tap down event.
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true; // Set pressed state
    });
    _controller.forward(); // Start the scaling animation forward.
  }

  // Handles the tap up event.
  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false; // Reset pressed state
    });
    _controller.reverse(); // Reverse the scaling animation.
    // Trigger the onPressed callback after a short delay to allow animation to start reversing.
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        // Check if the widget is still in the tree
        widget.onPressed();
      }
    });
  }

  // Handles the tap cancel event (e.g., dragging finger off the button).
  void _onTapCancel() {
    setState(() {
      _isPressed = false; // Reset pressed state
    });
    _controller.reverse(); // Reverse the scaling animation.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? Colors.blueAccent;
    final fgColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed || widget.elevation <= 0
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      spreadRadius: 1,
                      blurRadius: widget.elevation,
                      offset: Offset(0, widget.elevation / 2),
                    ),
                  ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: fgColor),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
