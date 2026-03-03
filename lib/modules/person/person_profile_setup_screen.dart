import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/helpers/image_picker_helper.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/person/widgets/multi_select_chips.dart';
import 'package:my_people/modules/person/widgets/profile_photo_avatar.dart';
import 'package:my_people/modules/person/widgets/profile_section_title.dart';
import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/utility/constants.dart';
import 'package:my_people/utility/date_helper.dart';

class PersonProfileSetupScreen extends ConsumerStatefulWidget {
  const PersonProfileSetupScreen({super.key, required this.person});

  final Person person;

  @override
  ConsumerState<PersonProfileSetupScreen> createState() =>
      _PersonProfileSetupScreenState();
}

class _PersonProfileSetupScreenState
    extends ConsumerState<PersonProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _instagramController;
  late final TextEditingController _twitterController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _occupationController;
  final TextEditingController _customInterestController =
      TextEditingController();

  File? _selectedImage;
  late String _currentPhotoPath;

  DateTime? _birthday;
  late List<String> _relationshipType;
  late List<String> _interests;
  late List<String> _dietaryRestrictions;
  String? _introvertExtrovert;
  String? _relationshipStatus;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    final p = widget.person;
    _nameController = TextEditingController(text: p.name);
    _instagramController = TextEditingController(text: p.socialInstagram);
    _twitterController = TextEditingController(text: p.socialTwitter);
    _linkedInController = TextEditingController(text: p.socialLinkedIn);
    _occupationController = TextEditingController(text: p.occupation);

    _currentPhotoPath = p.photo;
    if (!ImagePickerHelper.isAssetPath(_currentPhotoPath)) {
      _selectedImage = File(_currentPhotoPath);
    }

    _birthday = p.birthday;
    _relationshipType = List<String>.from(p.relationshipType ?? []);
    _interests = List<String>.from(p.interests ?? []);
    _dietaryRestrictions = List<String>.from(p.dietaryRestrictions ?? []);
    _introvertExtrovert = p.introvertExtrovert;
    _relationshipStatus = p.relationshipStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _linkedInController.dispose();
    _occupationController.dispose();
    _customInterestController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _pickImage() {
    ImagePickerHelper.showImageSourceBottomSheet(
      context: context,
      onImagePicked: (file) {
        if (file != null) {
          setState(() {
            _selectedImage = file;
            _currentPhotoPath = file.path;
          });
        }
      },
    );
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedPerson = Person(
        uuid: widget.person.uuid,
        name: _nameController.text.trim(),
        photo: _currentPhotoPath,
        info: widget.person.info,
        birthday: _birthday,
        relationshipType:
            _relationshipType.isNotEmpty ? _relationshipType : null,
        socialInstagram: _instagramController.text.trim().nullIfEmpty,
        socialTwitter: _twitterController.text.trim().nullIfEmpty,
        socialLinkedIn: _linkedInController.text.trim().nullIfEmpty,
        occupation: _occupationController.text.trim().nullIfEmpty,
        interests: _interests.isNotEmpty ? _interests : null,
        dietaryRestrictions:
            _dietaryRestrictions.isNotEmpty ? _dietaryRestrictions : null,
        introvertExtrovert: _introvertExtrovert,
        relationshipStatus: _relationshipStatus,
      );

      ref.read(peopleProvider.notifier).updatePersonDetails(updatedPerson);
      Navigator.pop(context);
    }
  }

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text(
          'Are you sure you want to delete this profile? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(peopleProvider.notifier).deletePerson(widget.person);
              Navigator.pop(context); // close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _addCustomInterest() {
    final val = _customInterestController.text.trim();
    if (val.isNotEmpty && !_interests.contains(val)) {
      setState(() {
        _interests.add(val);
        _customInterestController.clear();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Photo ────────────────────────────────────────────────
                  Center(
                    child: ProfilePhotoAvatar(
                      selectedImage: _selectedImage,
                      fallbackAsset: _currentPhotoPath,
                      onTap: _pickImage,
                      radius: 50,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Name ─────────────────────────────────────────────────
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),

                  // ── Basic Info ────────────────────────────────────────────
                  const ProfileSectionTitle('Basic Info'),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Birthday'),
                    subtitle: Text(
                      _birthday != null
                          ? DateHelper.formatBirthday(_birthday!)
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickBirthday,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _occupationController,
                    decoration: InputDecoration(
                      labelText: 'Occupation',
                      hintText: 'e.g. Gardener',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // ── Relationship ──────────────────────────────────────────
                  const ProfileSectionTitle('Relationship'),
                  MultiSelectChips(
                    options: ProfileFormConstants.relationshipOptions,
                    selected: _relationshipType,
                    onChanged: (updated) =>
                        setState(() => _relationshipType = updated),
                  ),

                  // ── Relationship Status ───────────────────────────────────
                  const ProfileSectionTitle('Relationship Status'),
                  SingleSelectChips(
                    options: ProfileFormConstants.relationshipStatusOptions,
                    selectedValue: _relationshipStatus,
                    onChanged: (val) =>
                        setState(() => _relationshipStatus = val),
                  ),

                  // ── Social Handles ────────────────────────────────────────
                  const ProfileSectionTitle('Social Handles'),
                  TextFormField(
                    controller: _instagramController,
                    decoration: InputDecoration(
                      labelText: 'Instagram',
                      prefixIcon: const Icon(Icons.camera_alt_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _twitterController,
                    decoration: InputDecoration(
                      labelText: 'Twitter/X',
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _linkedInController,
                    decoration: InputDecoration(
                      labelText: 'LinkedIn',
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // ── Interests & Hobbies ───────────────────────────────────
                  const ProfileSectionTitle('Interests & Hobbies'),
                  MultiSelectChips(
                    options: ProfileFormConstants.presetInterests,
                    selected: _interests,
                    onChanged: (updated) =>
                        setState(() => _interests = updated),
                  ),

                  // Custom interests
                  if (_interests.any((i) =>
                      !ProfileFormConstants.presetInterests.contains(i))) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _interests
                          .where((i) =>
                              !ProfileFormConstants.presetInterests.contains(i))
                          .map((custom) => InputChip(
                                label: Text(custom),
                                onDeleted: () =>
                                    setState(() => _interests.remove(custom)),
                                selectedColor:
                                    theme.colorScheme.primary.withAlpha(50),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customInterestController,
                          decoration: InputDecoration(
                            hintText: 'Add custom interest...',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onSubmitted: (_) => _addCustomInterest(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: theme.colorScheme.primary,
                        onPressed: _addCustomInterest,
                      ),
                    ],
                  ),

                  // ── Social Energy ─────────────────────────────────────────
                  const ProfileSectionTitle('Social Energy'),
                  SegmentedButton<String>(
                    segments: ProfileFormConstants.introvertExtrovertOptions
                        .map((option) => ButtonSegment<String>(
                              value: option,
                              label: Text(option,
                                  style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                    selected: {_introvertExtrovert ?? ''}
                        .where((e) => e.isNotEmpty)
                        .toSet(),
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _introvertExtrovert =
                            newSelection.isEmpty ? null : newSelection.first;
                      });
                    },
                    emptySelectionAllowed: true,
                  ),

                  // ── Dietary Restrictions ──────────────────────────────────
                  const ProfileSectionTitle('Dietary Restrictions'),
                  MultiSelectChips(
                    options: ProfileFormConstants.dietaryOptions,
                    selected: _dietaryRestrictions,
                    onChanged: (updated) =>
                        setState(() => _dietaryRestrictions = updated),
                  ),

                  // ── Action Buttons ────────────────────────────────────────
                  const SizedBox(height: 48),
                  _ActionButton(
                    label: 'Complete Profile',
                    onPressed: _saveProfile,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton.outlined(
                    label: 'Delete Profile',
                    onPressed: _confirmDeleteProfile,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

extension on String {
  /// Returns `null` if the string is empty, otherwise `this`.
  String? get nullIfEmpty => isEmpty ? null : this;
}

/// A full-width, tall action button used at the bottom of the profile setup
/// form.  Supports both filled and outlined variants.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  })  : color = null,
        _outlined = false;

  const _ActionButton.outlined({
    required this.label,
    required this.onPressed,
    required this.color,
  })  : backgroundColor = null,
        foregroundColor = null,
        _outlined = true;

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? color; // used for outlined variant
  final bool _outlined;

  @override
  Widget build(BuildContext context) {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    if (_outlined) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color!),
            shape: shape,
          ),
          child: Text(label, style: textStyle),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: shape,
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}
