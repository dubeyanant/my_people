import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:my_people/model/event.dart';
import 'package:my_people/providers/people_provider.dart';

class AddEventBottomSheet extends ConsumerStatefulWidget {
  final String personId;
  final Event? initialEvent;

  const AddEventBottomSheet({
    super.key,
    required this.personId,
    this.initialEvent,
  });

  @override
  ConsumerState<AddEventBottomSheet> createState() =>
      _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends ConsumerState<AddEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _selectedEmoji = '🗓️';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _selectedEmoji = widget.initialEvent!.emoji;
      _titleController.text = widget.initialEvent!.title;
      _descriptionController.text = widget.initialEvent!.description;
      _selectedDate = widget.initialEvent!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.initialEvent!.date);
    }
  }

  void _submitEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      final String emojiText = _selectedEmoji;
      final String titleText = _titleController.text.trim();
      final String descriptionText = _descriptionController.text.trim();

      final dateToSave = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newEvent = Event(
        id: widget.initialEvent?.id, // Keep ID if editing
        personUuid: widget.personId,
        emoji: emojiText,
        title: titleText,
        description: descriptionText,
        date: dateToSave,
      );

      if (widget.initialEvent != null) {
        ref
            .read(peopleProvider.notifier)
            .updatePersonEvent(widget.personId, newEvent);
      } else {
        ref
            .read(peopleProvider.notifier)
            .addEventToPerson(widget.personId, newEvent);
      }
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            setState(() {
              _selectedEmoji = emoji.emoji;
            });
            Navigator.pop(context);
          },
          config: Config(
            checkPlatformCompatibility: true,
            bottomActionBarConfig: BottomActionBarConfig(enabled: false),
            categoryViewConfig: CategoryViewConfig(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              iconColorSelected: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              dividerColor: Theme.of(context).colorScheme.secondaryFixedDim,
              iconColor: Theme.of(context).colorScheme.secondaryFixedDim,
            ),
          ),
        );
      },
    );
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showEmojiPicker,
                          child: Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            autofocus: true,
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'Add event title...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Add description...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _pickDate(context),
                          child: Text(
                            'Pick Date',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _pickTime(context),
                          child: Text(
                            'Pick Time',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitEvent,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      child: Text(
                        widget.initialEvent == null
                            ? 'Add Event'
                            : 'Save Event',
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

void showAddEventBottomSheet(
  BuildContext context,
  String personId, {
  Event? initialEvent,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddEventBottomSheet(
        personId: personId,
        initialEvent: initialEvent,
      );
    },
  );
}
