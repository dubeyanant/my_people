import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/person/person_profile_setup_screen.dart';
import 'package:my_people/utility/constants.dart';

class PersonDetailBottomSheet extends ConsumerStatefulWidget {
  const PersonDetailBottomSheet({super.key});

  @override
  ConsumerState<PersonDetailBottomSheet> createState() =>
      _PersonDetailBottomSheetState();
}

class _PersonDetailBottomSheetState
    extends ConsumerState<PersonDetailBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _selectedImage;
  late String _defaultImage;

  final List<String> _defaultImages = [
    'assets/profile_pictures/default1.webp',
    'assets/profile_pictures/default2.webp',
    'assets/profile_pictures/default3.webp',
    'assets/profile_pictures/default4.webp',
    'assets/profile_pictures/default5.webp',
    'assets/profile_pictures/default6.webp',
    'assets/profile_pictures/default7.webp',
    'assets/profile_pictures/default8.webp',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize default image randomly from _defaultImages list
    _defaultImage = _defaultImages[Random().nextInt(_defaultImages.length)];
  }

  // Method to check if a string starts with 'assets/'
  bool startsWithAssets(String input) {
    RegExp regex = RegExp(r'^assets/');
    return regex.hasMatch(input);
  }

  // Method to pick an image from gallery
  Future<void> _pickImage() async {
    AnalyticsHelper.trackFeatureUsage('pick_image');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  // Method to submit the form data
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final String name = _nameController.text;
      final String imagePath =
          _selectedImage != null ? _selectedImage!.path : _defaultImage;

      // Add new person
      final newPerson = Person(name: name.trim(), photo: imagePath, info: []);
      ref.read(peopleProvider.notifier).addPerson(newPerson);
      Navigator.pop(context); // Close bottom sheet

      // Navigate to the profile setup screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonProfileSetupScreen(person: newPerson),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.addPerson,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : AssetImage(_defaultImage) as ImageProvider,
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.edit,
                          size: 12,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                autofocus: true,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.personDetailTextFieldLabel,
                  hintStyle: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                  hintText: AppStrings.personDetailTextFieldHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.personDetailTextFieldError;
                  }
                  return null;
                },
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text(AppStrings.addPerson),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show PersonBioScreen as a bottom sheet
void showPersonDetailBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: PersonDetailBottomSheet(),
        ),
      );
    },
  );
}
