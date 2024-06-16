import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/utility/constants.dart';

class PersonDetailBottomSheet extends StatefulWidget {
  final Person? personToEdit;

  const PersonDetailBottomSheet({super.key, this.personToEdit});

  @override
  State<PersonDetailBottomSheet> createState() =>
      _PersonDetailBottomSheetState();
}

class _PersonDetailBottomSheetState extends State<PersonDetailBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final PeopleController pc = Get.put(PeopleController());

  File? _selectedImage;
  late String _defaultImage;

  final List<String> _defaultImages = [
    'assets/default1.webp',
    'assets/default2.webp',
    'assets/default3.webp',
    'assets/default4.webp',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize default image randomly from _defaultImages list
    _defaultImage = _defaultImages[Random().nextInt(_defaultImages.length)];

    // Populate form fields if editing an existing person
    if (widget.personToEdit != null) {
      _nameController.text = widget.personToEdit!.name;
      // Check if the person's photo is an asset or a file path
      if (startsWithAssets(widget.personToEdit!.photo)) {
        _defaultImage = widget.personToEdit!.photo;
      } else {
        _selectedImage = File(widget.personToEdit!.photo);
      }
    }
  }

  // Method to check if a string starts with 'assets/'
  bool startsWithAssets(String input) {
    RegExp regex = RegExp(r'^assets/');
    return regex.hasMatch(input);
  }

  // Method to pick an image from gallery
  Future<void> _pickImage() async {
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

      if (widget.personToEdit != null) {
        // Update existing person
        pc.updatePerson(widget.personToEdit!, name, imagePath);
      } else {
        // Add new person
        pc.addPerson(Person(name: name.trim(), photo: imagePath, info: []));
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.personToEdit == null
                    ? AppStrings.addPerson
                    : AppStrings.editPerson,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                autofocus: true,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.personDetailTextFieldLabel,
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
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : AssetImage(_defaultImage) as ImageProvider,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 12,
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  widget.personToEdit == null
                      ? AppStrings.addPerson
                      : AppStrings.savePerson,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show PersonBioScreen as a bottom sheet
void showPersonDetailBottomSheet(BuildContext context, {Person? personToEdit}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: PersonDetailBottomSheet(personToEdit: personToEdit),
        ),
      );
    },
  );
}
