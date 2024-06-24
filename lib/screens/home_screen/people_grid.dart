import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/screens/person_detail_bottomsheet.dart';
import 'package:my_people/screens/person_screen.dart';
import 'package:my_people/utility/constants.dart';

class PeopleGrid extends StatelessWidget {
  const PeopleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final PeopleController pc = Get.put(PeopleController());
    pc.fetchPeople();

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
            value: 'edit',
            child: Text(AppStrings.edit),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text(AppStrings.delete),
          ),
        ],
      );

      // Handle the selected action from the popup menu
      if (result == 'delete') {
        pc.deletePerson(person);
      } else if (result == 'edit') {
        // Navigate to PersonBioScreen to edit the selected person
        if (context.mounted) {
          showPersonDetailBottomSheet(context, personToEdit: person);
        }
      }
    }

    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GridView.count(
          childAspectRatio: 17 / 20,
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 16, // Space between columns
          mainAxisSpacing: 24, // Space between rows
          children: pc.filteredPeople.map((person) {
            final isFile = File(person.photo).existsSync();
            return GestureDetector(
              onLongPressStart: (details) =>
                  showPopupMenu(context, person, details.globalPosition),
              onTap: () {
                Get.to(() => PersonScreen(person.uuid));
                Future.delayed(const Duration(milliseconds: 10), () {
                  pc.isSearchOpen.value = false;
                });
              },
              child: GridTile(
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: isFile
                            ? Image.file(
                                File(person.photo),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Image.asset(
                                person.photo,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      person.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
