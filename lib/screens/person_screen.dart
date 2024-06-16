import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/model/person.dart';

class PersonScreen extends StatelessWidget {
  final Person person;
  const PersonScreen(this.person, {super.key});

  @override
  Widget build(BuildContext context) {
    final PeopleController pc = Get.put(PeopleController());
    final isFile = File(person.photo).existsSync();

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
                                person.info[index] = 'New Info';
                                pc.updatePersonInfo(person.uuid, person.info);
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
                                child: Obx(() {
                                  Person personNew = pc.people.firstWhere(
                                      (element) => element.uuid == person.uuid);

                                  return Text(personNew.info[index]);
                                }),
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
  }
}
