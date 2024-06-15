import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/screens/person_bio_screen.dart';

class PeopleGrid extends StatelessWidget {
  const PeopleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final PeopleController pc = Get.put(PeopleController());

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
            child: Text('Edit'),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      );

      // Handle the selected action from the popup menu
      if (result == 'delete') {
        pc.deletePerson(person);
      } else if (result == 'edit') {
        // Navigate to PersonBioScreen to edit the selected person
        Get.to(() => PersonBioScreen(personToEdit: person));
      }
    }

    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 16, // Space between columns
          mainAxisSpacing: 24, // Space between rows
          children: pc.people.map((person) {
            final isFile = File(person.photo).existsSync();
            return GestureDetector(
              onLongPressStart: (details) {
                // Show the popup menu on long press
                showPopupMenu(context, person, details.globalPosition);
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
