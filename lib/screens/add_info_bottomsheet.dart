import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/utility/constants.dart';

class AddInfoBottomSheet extends StatefulWidget {
  final String personId;

  const AddInfoBottomSheet({super.key, required this.personId});

  @override
  State<AddInfoBottomSheet> createState() => _AddInfoBottomSheetState();
}

class _AddInfoBottomSheetState extends State<AddInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _infoController = TextEditingController();
  final PeopleController pc = Get.put(PeopleController());

  void _submitInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      final String info = _infoController.text.trim();
      pc.addInfoToPerson(widget.personId, info);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      autofocus: true,
                      controller: _infoController,
                      decoration: InputDecoration(
                        labelText: AppStrings.addInfoTextFieldLabel,
                        hintText: AppStrings.addInfoTextFieldHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.addInfoTextFieldError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitInfo,
                      child: const Text(AppStrings.saveInfoButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showAddInfoBottomSheet(BuildContext context, String personId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddInfoBottomSheet(personId: personId);
    },
  );
}
