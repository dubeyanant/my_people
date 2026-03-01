import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/model/person_info.dart';
import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/utility/constants.dart';

class AddInfoBottomSheet extends ConsumerStatefulWidget {
  final String personId;
  final PersonInfo? initialInfo;
  final int? infoIndex;

  const AddInfoBottomSheet({
    super.key,
    required this.personId,
    this.initialInfo,
    this.infoIndex,
  });

  @override
  ConsumerState<AddInfoBottomSheet> createState() => _AddInfoBottomSheetState();
}

class _AddInfoBottomSheetState extends ConsumerState<AddInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _infoController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialInfo != null) {
      _infoController.text = widget.initialInfo!.text;
      _selectedDate = widget.initialInfo!.date;
    }
  }

  void _submitInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      final String infoText = _infoController.text.trim();
      final dateToSave = _selectedDate ?? DateTime.now();

      final newInfo = PersonInfo(
        text: capitalize(infoText),
        date: dateToSave,
      );

      if (widget.initialInfo != null && widget.infoIndex != null) {
        ref
            .read(peopleProvider.notifier)
            .updatePersonInfo(widget.personId, newInfo, widget.infoIndex!);
      } else {
        ref
            .read(peopleProvider.notifier)
            .addInfoToPerson(widget.personId, newInfo);
      }
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
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
        color: Theme.of(context).colorScheme.surface,
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
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(150),
                        ),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? AppStrings.selectDateLabel
                              : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _pickDate(context),
                          child: Text(
                            AppStrings.pickDateButton,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
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
  PersonInfo? initialInfo,
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
