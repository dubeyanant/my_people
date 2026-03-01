import 'package:flutter/material.dart';

import 'package:my_people/model/person.dart';

class ProfileDetailsPanel extends StatefulWidget {
  final Person person;

  const ProfileDetailsPanel({super.key, required this.person});

  @override
  State<ProfileDetailsPanel> createState() => _ProfileDetailsPanelState();
}

class _ProfileDetailsPanelState extends State<ProfileDetailsPanel> {
  bool _isExpanded = false;

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) return monthNames[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Collect all available fields into a list of widgets
    final List<Widget> detailChips = [];

    // Birthday
    if (widget.person.birthday != null) {
      final b = widget.person.birthday!;
      final bString =
          '${b.day} ${_getMonthName(b.month)}${b.year != DateTime.now().year ? ', ${b.year}' : ''}';
      detailChips.add(_buildChip('🎂', bString));
    }

    // Occupation
    if (widget.person.occupation != null &&
        widget.person.occupation!.isNotEmpty) {
      detailChips.add(_buildChip('💼', widget.person.occupation!));
    }

    // Relationship Type
    if (widget.person.relationshipType != null &&
        widget.person.relationshipType!.isNotEmpty) {
      detailChips
          .add(_buildChip('🤝', widget.person.relationshipType!.join(', ')));
    }

    // Relationship Status
    if (widget.person.relationshipStatus != null &&
        widget.person.relationshipStatus!.isNotEmpty) {
      detailChips.add(_buildChip('❤️', widget.person.relationshipStatus!));
    }

    // Introvert/Extrovert
    if (widget.person.introvertExtrovert != null &&
        widget.person.introvertExtrovert!.isNotEmpty) {
      detailChips.add(_buildChip('🔋', widget.person.introvertExtrovert!));
    }

    // Interests
    if (widget.person.interests != null &&
        widget.person.interests!.isNotEmpty) {
      detailChips.add(_buildChip('⭐', widget.person.interests!.join(', ')));
    }

    // Dietary
    if (widget.person.dietaryRestrictions != null &&
        widget.person.dietaryRestrictions!.isNotEmpty) {
      detailChips.add(
          _buildChip('🍽️', widget.person.dietaryRestrictions!.join(', ')));
    }

    // Socials
    if (widget.person.socialInstagram != null &&
        widget.person.socialInstagram!.isNotEmpty) {
      detailChips.add(_buildChip('📸', widget.person.socialInstagram!));
    }
    if (widget.person.socialTwitter != null &&
        widget.person.socialTwitter!.isNotEmpty) {
      detailChips.add(_buildChip('🐦', widget.person.socialTwitter!));
    }
    if (widget.person.socialLinkedIn != null &&
        widget.person.socialLinkedIn!.isNotEmpty) {
      detailChips.add(_buildChip('🔗', widget.person.socialLinkedIn!));
    }

    // If no details at all, return empty
    if (detailChips.isEmpty) return const SizedBox.shrink();

    // Determine how many to show based on expansion state
    final int defaultVisibleCount = 2;
    final bool canExpand = detailChips.length > defaultVisibleCount;
    final List<Widget> visibleChips = _isExpanded || !canExpand
        ? detailChips
        : detailChips.sublist(0, defaultVisibleCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: visibleChips,
          ),
          if (canExpand) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? 'Show less' : 'Show more',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildChip(String emoji, String text) {
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
          Container(
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
