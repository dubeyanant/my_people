import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';

class PersonScreen extends StatelessWidget {
  final String id;
  const PersonScreen(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PeopleController pc = Get.put(PeopleController());
      final person = pc.people.firstWhere((element) => element.uuid == id);
      final isFile = File(person.photo).existsSync();

      void showPopupMenu(
          BuildContext context, int infoItemIndex, Offset offset) async {
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
          pc.deletePersonInfo(person.uuid, infoItemIndex);
        } else if (result == 'edit') {}
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(person.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search for the info block
              },
            ),
          ],
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: isFile
                    ? Image.file(
                        File(person.photo),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ).image
                    : Image.asset(
                        person.photo,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ).image,
              ),
              person.info.isEmpty
                  ? Column(
                      children: [
                        Container(
                          color: Colors.black,
                          width: 2,
                          height: 80,
                        ),
                        IconButton.filled(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Add a detail and it will appear here!'),
                      ],
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: person.info.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                color: Colors.black,
                                width: 2,
                                height: 80,
                              ),
                              GestureDetector(
                                onTap: () {
                                  // person.info[index] = 'New Info';
                                  // pc.updatePersonInfo(person.uuid, person.info);
                                  //todo: implement edit info
                                },
                                onLongPressStart: (details) {
                                  showPopupMenu(
                                    context,
                                    index,
                                    details.globalPosition,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  width: double.maxFinite,
                                  child: Text(person.info[index]),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
        floatingActionButton: person.info.isEmpty
            ? null
            : FloatingActionButton(
                tooltip: 'Add Detail',
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
      );
    });
  }
}
