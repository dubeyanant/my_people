import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/screens/add_person_screen.dart';
import 'package:my_people/screens/home_screen/empty_home.dart';
import 'package:my_people/screens/home_screen/people_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final PeopleController pc = Get.put(PeopleController());

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text('My People'),
          centerTitle: true,
        ),
        body: pc.people.isEmpty ? const EmptyHome() : const PeopleGrid(),
        floatingActionButton: pc.people.isEmpty
            ? null
            : FloatingActionButton(
                tooltip: 'Add Person',
                onPressed: () => Get.to(() => const AddPersonScreen()),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
