import 'dart:async';

import 'package:flutter/material.dart';

import 'package:my_people/utility/constants.dart';

class AddProfileTooltip extends StatefulWidget {
  const AddProfileTooltip({super.key});

  @override
  State<AddProfileTooltip> createState() => _AddProfileTooltipState();
}

class _AddProfileTooltipState extends State<AddProfileTooltip> {
  final List<String> _animatedTexts = [
    "an acquaintance",
    "someone important",
    "a friend",
    "your aunt",
    "a colleague",
    "your crush",
    "a business partner",
    "your new date",
    "a family member",
    "a client",
    "your new neighbor",
    "a customer",
    "someone special",
    "your new boss",
    "a stranger",
  ];

  int _currentWordIndex = 0;
  String _displayedText = "";
  Timer? _typingTimer;
  bool _isTyping = true; // true for typing, false for retracting
  bool _isPausing = false; // true when pausing between phases

  // Animation speeds and pauses
  final Duration _typingSpeed = const Duration(milliseconds: 100);
  final Duration _retractingSpeed = const Duration(milliseconds: 50);
  final Duration _pauseAfterTyping =
      const Duration(milliseconds: 1500); // Pause after a word is fully typed
  final Duration _pauseAfterRetracting =
      const Duration(milliseconds: 500); // Pause after a word is retracted

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    if (_animatedTexts.isEmpty) return;
    _isPausing = false;
    _animateText();
  }

  void _animateText() {
    if (_isPausing) return; // Don't do anything if we are in a forced pause

    final currentWord = _animatedTexts[_currentWordIndex];

    if (_isTyping) {
      // Typing logic
      if (_displayedText.length < currentWord.length) {
        _displayedText = currentWord.substring(0, _displayedText.length + 1);
        _typingTimer = Timer(_typingSpeed, () => setState(_animateText));
      } else {
        // Word fully typed, pause then switch to retracting
        _isPausing = true;
        _typingTimer = Timer(_pauseAfterTyping, () {
          _isTyping = false;
          _isPausing = false;
          setState(_animateText);
        });
      }
    } else {
      // Retracting logic
      if (_displayedText.isNotEmpty) {
        _displayedText = _displayedText.substring(0, _displayedText.length - 1);
        _typingTimer = Timer(_retractingSpeed, () => setState(_animateText));
      } else {
        // Word fully retracted, pause then switch to next word and typing
        _isPausing = true;
        _typingTimer = Timer(_pauseAfterRetracting, () {
          _isTyping = true;
          _isPausing = false;
          _currentWordIndex = (_currentWordIndex + 1) % _animatedTexts.length;
          setState(_animateText);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.homeScreenTagline,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _displayedText.isEmpty ? "" : _displayedText,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
