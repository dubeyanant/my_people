import 'package:flutter/material.dart';

class SuggestionChips extends StatelessWidget {
  final String personName;
  final ValueChanged<String> onSuggestionTap;

  const SuggestionChips({
    super.key,
    required this.personName,
    required this.onSuggestionTap,
  });

  List<String> get _suggestions => [
        'Summarize everything I know about $personName',
        'What\'s $personName\'s birthday?',
        'Suggest some gift ideas',
        'Fun activities to do with $personName',
        'Suggest a conversation starter',
        'What are their interests?',
        'Help me write a birthday wish for them',
        'What should I remember about $personName?',
      ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(_suggestions.sublist(0, 4), colorScheme),
          _buildRow(_suggestions.sublist(4), colorScheme),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> items, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: colorScheme.secondaryContainer,
                side: BorderSide(
                  color: colorScheme.outline.withAlpha(60),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => onSuggestionTap(suggestion),
              ),
            ),
          )
          .toList(),
    );
  }
}
