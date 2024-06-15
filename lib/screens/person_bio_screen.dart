import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/model/person.dart';

class PersonBioScreen extends StatefulWidget {
  final Person? personToEdit;

  const PersonBioScreen({super.key, this.personToEdit});

  @override
  State<PersonBioScreen> createState() => _PersonBioScreenState();
}

class _PersonBioScreenState extends State<PersonBioScreen> {
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
    _defaultImage = _defaultImages[Random().nextInt(_defaultImages.length)];

    if (widget.personToEdit != null) {
      // Initialize fields if editing an existing person
      _nameController.text = widget.personToEdit!.name;
      !startsWithAssets(widget.personToEdit!.photo)
          ? _selectedImage = File(widget.personToEdit!.photo)
          : _defaultImage = widget.personToEdit!.photo;
    }
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
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final imagePath =
          _selectedImage != null ? _selectedImage!.path : _defaultImage;

      if (widget.personToEdit != null) {
        // Update existing person
        pc.updatePerson(widget.personToEdit!, name, imagePath);
      } else {
        // Add new person
        pc.addPerson(Person(name: name, photo: imagePath, info: []));
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.personToEdit == null ? 'Add Person' : 'Edit Person')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
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
                child: Text(widget.personToEdit == null
                    ? 'Add Person'
                    : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
