import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';

class PeopleGrid extends StatelessWidget {
  const PeopleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final PeopleController pc = Get.put(PeopleController());

    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 16, // Space between columns
          mainAxisSpacing: 24, // Space between rows
          children: pc.people.map((person) {
            final isFile = File(person.photo).existsSync();
            return GridTile(
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
            );
          }).toList(),
        ),
      ),
    );
  }
}
