import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/providers/people_provider.dart';

class PersonProfileSetupScreen extends ConsumerStatefulWidget {
  final Person person;

  const PersonProfileSetupScreen({super.key, required this.person});

  @override
  ConsumerState<PersonProfileSetupScreen> createState() =>
      _PersonProfileSetupScreenState();
}

class _PersonProfileSetupScreenState
    extends ConsumerState<PersonProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _linkedInController;
  late TextEditingController _occupationController;
  late TextEditingController _customInterestController;

  File? _selectedImage;
  late String _currentPhoto;

  DateTime? _birthday;
  List<String> _relationshipType = [];
  List<String> _interests = [];
  List<String> _dietaryRestrictions = [];
  String? _introvertExtrovert;
  String? _relationshipStatus;

  final List<String> _relationshipOptions = [
    'Friend',
    'Close Friend',
    'Family',
    'Colleague',
    'Client',
    'Bae',
    'Neighbour',
    'Other'
  ];

  final List<String> _presetInterests = [
    'Travel',
    'Music',
    'Gaming',
    'Sports',
    'Reading',
    'Cooking',
    'Fitness',
    'Art',
    'Movies',
    'Tech',
    'Fashion',
    'Nature'
  ];

  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Kosher',
    'Nut Allergy',
    'Lactose Intolerant',
    'No Restrictions',
    'Other'
  ];

  final List<String> _introvertExtrovertOptions = [
    'Introvert',
    'Ambivert',
    'Extrovert'
  ];

  final List<String> _relationshipStatusOptions = [
    'Single',
    'In a Relationship',
    'Married',
    'Divorced',
    'Widowed'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _instagramController =
        TextEditingController(text: widget.person.socialInstagram);
    _twitterController =
        TextEditingController(text: widget.person.socialTwitter);
    _linkedInController =
        TextEditingController(text: widget.person.socialLinkedIn);
    _occupationController =
        TextEditingController(text: widget.person.occupation);
    _customInterestController = TextEditingController();

    _currentPhoto = widget.person.photo;
    if (!startsWithAssets(_currentPhoto)) {
      _selectedImage = File(_currentPhoto);
    }

    _birthday = widget.person.birthday;
    _relationshipType = List.from(widget.person.relationshipType ?? []);
    _interests = List.from(widget.person.interests ?? []);
    _dietaryRestrictions = List.from(widget.person.dietaryRestrictions ?? []);
    _introvertExtrovert = widget.person.introvertExtrovert;
    _relationshipStatus = widget.person.relationshipStatus;
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

  bool startsWithAssets(String input) {
    RegExp regex = RegExp(r'^assets/');
    return regex.hasMatch(input);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _currentPhoto = pickedFile.path;
      }
    });
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedPerson = Person(
        uuid: widget.person.uuid,
        name: _nameController.text.trim(),
        photo: _currentPhoto,
        info: widget.person.info,
        birthday: _birthday,
        relationshipType:
            _relationshipType.isNotEmpty ? _relationshipType : null,
        socialInstagram: _instagramController.text.trim().isNotEmpty
            ? _instagramController.text.trim()
            : null,
        socialTwitter: _twitterController.text.trim().isNotEmpty
            ? _twitterController.text.trim()
            : null,
        socialLinkedIn: _linkedInController.text.trim().isNotEmpty
            ? _linkedInController.text.trim()
            : null,
        occupation: _occupationController.text.trim().isNotEmpty
            ? _occupationController.text.trim()
            : null,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips(
      List<String> options, List<String> selectedList) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedList.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedList.add(option);
              } else {
                selectedList.remove(option);
              }
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectChips(List<String> options, String? selectedValue,
      ValueChanged<String?> onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            onSelected(selected ? option : null);
          },
          selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                  // Header: Photo and Name
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : AssetImage(_currentPhoto) as ImageProvider,
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),

                  _buildSectionTitle('Basic Info'),

                  // Birthday
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Birthday'),
                    subtitle: Text(_birthday != null
                        ? '${_birthday!.day} ${_getMonthName(_birthday!.month)}${_birthday!.year != DateTime.now().year ? ', ${_birthday!.year}' : ''}'
                        : 'Not set'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickBirthday,
                  ),

                  const SizedBox(height: 12),

                  // Occupation
                  TextFormField(
                    controller: _occupationController,
                    decoration: InputDecoration(
                      labelText: 'Occupation',
                      hintText: 'e.g. Gardener',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  _buildSectionTitle('Relationship'),
                  _buildMultiSelectChips(
                      _relationshipOptions, _relationshipType),

                  _buildSectionTitle('Relationship Status'),
                  _buildSingleSelectChips(
                      _relationshipStatusOptions, _relationshipStatus, (val) {
                    setState(() => _relationshipStatus = val);
                  }),

                  _buildSectionTitle('Social Handles'),
                  TextFormField(
                    controller: _instagramController,
                    decoration: InputDecoration(
                      labelText: 'Instagram',
                      prefixIcon: const Icon(Icons.camera_alt_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _twitterController,
                    decoration: InputDecoration(
                      labelText: 'Twitter/X',
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _linkedInController,
                    decoration: InputDecoration(
                      labelText: 'LinkedIn',
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  _buildSectionTitle('Interests & Hobbies'),
                  _buildMultiSelectChips(_presetInterests, _interests),

                  // Custom Interest
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interests
                        .where((i) => !_presetInterests.contains(i))
                        .map((customInterest) {
                      return InputChip(
                        label: Text(customInterest),
                        onDeleted: () {
                          setState(() {
                            _interests.remove(customInterest);
                          });
                        },
                        selectedColor: theme.colorScheme.primary.withAlpha(50),
                      );
                    }).toList(),
                  ),
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
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty &&
                                !_interests.contains(val.trim())) {
                              setState(() {
                                _interests.add(val.trim());
                                _customInterestController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          final val = _customInterestController.text.trim();
                          if (val.isNotEmpty && !_interests.contains(val)) {
                            setState(() {
                              _interests.add(val);
                              _customInterestController.clear();
                            });
                          }
                        },
                      )
                    ],
                  ),

                  _buildSectionTitle('Social Energy'),
                  SegmentedButton<String>(
                    segments: _introvertExtrovertOptions.map((option) {
                      return ButtonSegment<String>(
                        value: option,
                        label:
                            Text(option, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    selected: {_introvertExtrovert ?? ''}
                        .where((e) => e.isNotEmpty)
                        .toSet(),
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        if (newSelection.isEmpty) {
                          _introvertExtrovert = null;
                        } else {
                          _introvertExtrovert = newSelection.first;
                        }
                      });
                    },
                    emptySelectionAllowed: true,
                  ),

                  _buildSectionTitle('Dietary Restrictions'),
                  _buildMultiSelectChips(_dietaryOptions, _dietaryRestrictions),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Complete Profile',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Profile'),
                            content: const Text(
                                'Are you sure you want to delete this profile? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(peopleProvider.notifier)
                                      .deletePerson(widget.person);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete Profile',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
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
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
  }
}
