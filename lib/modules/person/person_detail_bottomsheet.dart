import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/helpers/image_picker_helper.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/person/widgets/profile_photo_avatar.dart';
import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/utility/constants.dart';

/// Bottom sheet used to create a new [Person] with a name and photo.
///
/// After the person is added to the provider, [onPersonAdded] is called with
/// the newly created person so the caller can decide what to do next (e.g.
/// navigate to the profile-setup screen).
class PersonDetailBottomSheet extends ConsumerStatefulWidget {
  const PersonDetailBottomSheet({
    super.key,
    required this.onPersonAdded,
  });

  /// Called after the new person has been added to [peopleProvider].
  final void Function(Person newPerson) onPersonAdded;

  @override
  ConsumerState<PersonDetailBottomSheet> createState() =>
      _PersonDetailBottomSheetState();
}

class _PersonDetailBottomSheetState
    extends ConsumerState<PersonDetailBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _selectedImage;
  late final String _defaultImage;

  @override
  void initState() {
    super.initState();
    _defaultImage = ImagePickerHelper.randomDefaultImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final imagePath =
          _selectedImage != null ? _selectedImage!.path : _defaultImage;
      final newPerson = Person(
        name: _nameController.text.trim(),
        photo: imagePath,
        info: [],
      );

      ref.read(peopleProvider.notifier).addPerson(newPerson);
      Navigator.pop(context); // close this bottom sheet
      widget.onPersonAdded(newPerson);
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
              ProfilePhotoAvatar(
                selectedImage: _selectedImage,
                fallbackAsset: _defaultImage,
                onTap: () => ImagePickerHelper.showImageSourceBottomSheet(
                  context: context,
                  onImagePicked: (file) {
                    if (file != null) setState(() => _selectedImage = file);
                  },
                ),
                radius: 40,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows [PersonDetailBottomSheet] as a modal bottom sheet.
///
/// [onPersonAdded] is forwarded to the sheet and called once the new person
/// has been persisted.  Callers should use this callback to navigate to the
/// profile-setup screen (or perform any other post-creation action).
void showPersonDetailBottomSheet(
  BuildContext context, {
  required void Function(Person newPerson) onPersonAdded,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: PersonDetailBottomSheet(onPersonAdded: onPersonAdded),
        ),
      );
    },
  );
}
