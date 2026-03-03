import 'package:flutter/material.dart';

/// A [Wrap] of [FilterChip]s that allows multiple simultaneous selections.
///
/// [options] is the full list of available choices.  [selected] is the current
/// selection.  Whenever the selection changes [onChanged] is called with the
/// updated list.
class MultiSelectChips extends StatelessWidget {
  const MultiSelectChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (value) {
            final updated = List<String>.from(selected);
            if (value) {
              updated.add(option);
            } else {
              updated.remove(option);
            }
            onChanged(updated);
          },
          selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }
}

/// A [Wrap] of [ChoiceChip]s that allows at most one selection at a time.
///
/// [options] is the full list of available choices.  [selectedValue] is the
/// currently selected option (or `null` for no selection).  [onChanged] is
/// called with the new value (or `null` when the selection is cleared).
class SingleSelectChips extends StatelessWidget {
  const SingleSelectChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) => onChanged(selected ? option : null),
          selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
        );
      }).toList(),
    );
  }
}
