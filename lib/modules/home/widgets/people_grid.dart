import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/home/widgets/tooltip_arrows/add_more_profile_tooltip.dart';
import 'package:my_people/modules/home/widgets/tooltip_arrows/profile_tooltip.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';
import 'package:my_people/modules/person/person_screen.dart';
import 'package:my_people/utility/constants.dart';

class PeopleGrid extends ConsumerWidget {
  const PeopleGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPeople = ref.watch(filteredPeopleProvider);
    final isSearchFocused = ref.watch(isHomeScreenSearchFocusedProvider);

    // Method to show a popup menu for editing or deleting a person
    void showPopupMenu(
        BuildContext context, Person person, Offset offset) async {
      final result = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          offset.dx + 1,
          offset.dy + 1,
        ),
        items: [
          const PopupMenuItem<String>(
            value: AppStrings.edit,
            child: Text(AppStrings.edit),
          ),
          const PopupMenuItem<String>(
            value: AppStrings.delete,
            child: Text(AppStrings.delete),
          ),
        ],
      );

      // Handle the selected action from the popup menu
      if (result == AppStrings.delete) {
        ref.read(peopleProvider.notifier).deletePerson(person);
      } else if (result == AppStrings.edit) {
        // Navigate to PersonBioScreen to edit the selected person
        if (context.mounted) {
          showPersonDetailBottomSheet(context, personToEdit: person);
        }
      }
    }

    // Check if there's exactly one person in the list
    final bool showTooltip = filteredPeople.length == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          GridView.count(
            // Making the aspect ratio more elongated (height-wise)
            childAspectRatio: 2 / 3,
            padding: const EdgeInsets.only(top: 16),
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 16, // Space between columns
            mainAxisSpacing: 24, // Space between rows
            children: filteredPeople.map((person) {
              final isFile = File(person.photo).existsSync();
              return GestureDetector(
                onLongPressStart: (details) =>
                    showPopupMenu(context, person, details.globalPosition),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonScreen(person.uuid),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    // Profile image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isFile
                          ? Image.file(
                              File(person.photo),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.asset(
                              person.photo,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                    // Gradient overlay for the name at the bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withAlpha(204),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Text(
                          person.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          // Only show tooltips if there's one person AND search isn't focused
          if (showTooltip && !isSearchFocused) ...[
            ProfileTooltip(),
            AddMoreProfileTooltip(),
          ],
        ],
      ),
    );
  }
}
