import 'package:flutter/material.dart';

import 'package:my_people/model/person.dart';
import 'package:my_people/utility/date_helper.dart';

/// Displays a collapsible set of detail chips for a [Person].
///
/// Chips are only shown for non-null, non-empty fields.  If there are no
/// details at all the widget renders as an empty [SizedBox].
class ProfileDetailsPanel extends StatefulWidget {
  const ProfileDetailsPanel({super.key, required this.person});

  final Person person;

  @override
  State<ProfileDetailsPanel> createState() => _ProfileDetailsPanelState();
}

class _ProfileDetailsPanelState extends State<ProfileDetailsPanel> {
  static const int _defaultVisibleCount = 2;
  bool _isExpanded = false;

  /// Builds the ordered list of (emoji, text) pairs for all filled fields.
  List<({String emoji, String text})> _buildDetailEntries() {
    final p = widget.person;
    return [
      if (p.birthday != null)
        (emoji: '🎂', text: DateHelper.formatBirthday(p.birthday!)),
      if (p.occupation?.isNotEmpty ?? false) (emoji: '💼', text: p.occupation!),
      if (p.relationshipType?.isNotEmpty ?? false)
        (emoji: '🤝', text: p.relationshipType!.join(', ')),
      if (p.relationshipStatus?.isNotEmpty ?? false)
        (emoji: '❤️', text: p.relationshipStatus!),
      if (p.introvertExtrovert?.isNotEmpty ?? false)
        (emoji: '🔋', text: p.introvertExtrovert!),
      if (p.interests?.isNotEmpty ?? false)
        (emoji: '⭐', text: p.interests!.join(', ')),
      if (p.dietaryRestrictions?.isNotEmpty ?? false)
        (emoji: '🍽️', text: p.dietaryRestrictions!.join(', ')),
      if (p.socialInstagram?.isNotEmpty ?? false)
        (emoji: '📸', text: p.socialInstagram!),
      if (p.socialTwitter?.isNotEmpty ?? false)
        (emoji: '🐦', text: p.socialTwitter!),
      if (p.socialLinkedIn?.isNotEmpty ?? false)
        (emoji: '🔗', text: p.socialLinkedIn!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildDetailEntries();
    if (entries.isEmpty) return const SizedBox.shrink();

    final canExpand = entries.length > _defaultVisibleCount;
    final visible = (_isExpanded || !canExpand)
        ? entries
        : entries.sublist(0, _defaultVisibleCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: visible
                .map((e) => _DetailChip(emoji: e.emoji, text: e.text))
                .toList(),
          ),
          if (canExpand) ...[
            const SizedBox(height: 8),
            _ExpandToggle(
              isExpanded: _isExpanded,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({required this.isExpanded, required this.onTap});

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary.withAlpha(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExpanded ? 'Show less' : 'Show more',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
