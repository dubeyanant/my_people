import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/utility/constants.dart';

class AddInfoBottomSheet extends StatefulWidget {
  final String personId;
  final String? initialInfo;
  final int? infoIndex;

  const AddInfoBottomSheet({
    super.key,
    required this.personId,
    this.initialInfo,
    this.infoIndex,
  });

  @override
  State<AddInfoBottomSheet> createState() => _AddInfoBottomSheetState();
}

class _AddInfoBottomSheetState extends State<AddInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _infoController = TextEditingController();
  final PeopleController pc = Get.put(PeopleController());

  @override
  void initState() {
    super.initState();
    if (widget.initialInfo != null) {
      _infoController.text = widget.initialInfo!;
    }
  }

  void _submitInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      final String info = _infoController.text.trim();
      if (widget.initialInfo != null && widget.infoIndex != null) {
        pc.updatePersonInfo(
            widget.personId, capitalize(info), widget.infoIndex!);
      } else {
        pc.addInfoToPerson(widget.personId, capitalize(info));
      }
      Get.back();
    }
  }

  /// Passing true will capitalize all words in the text, and false will only capitalize the first word.
  String capitalize(String text, {bool capitalizeAll = false}) {
    if (text.isEmpty) return text;
    return capitalizeAll
        ? text.toLowerCase().split(' ').map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1);
          }).join(' ')
        : text[0].toUpperCase() + text.substring(1).toLowerCase();
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
                      minLines: 1,
                      maxLines: 3,
                      controller: _infoController,
                      decoration: InputDecoration(
                        labelText: widget.initialInfo == null
                            ? AppStrings.addInfoTextFieldLabel
                            : AppStrings.editInfoTextFieldLabel,
                        hintStyle: TextStyle(color: Colors.grey),
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
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      child: Text(
                        widget.initialInfo == null
                            ? AppStrings.addInfoButton
                            : AppStrings.saveInfoButton,
                      ),
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

void showAddInfoBottomSheet(
  BuildContext context,
  String personId, {
  String? initialInfo,
  int? infoIndex,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddInfoBottomSheet(
        personId: personId,
        initialInfo: initialInfo,
        infoIndex: infoIndex,
      );
    },
  );
}
