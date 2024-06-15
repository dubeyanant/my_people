import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/screens/person_bio_screen.dart';
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
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        ),
        body: pc.people.isEmpty ? const EmptyHome() : const PeopleGrid(),
        floatingActionButton: pc.people.isEmpty
            ? null
            : FloatingActionButton(
                tooltip: 'Add Person',
                onPressed: () => Get.to(() => const PersonBioScreen()),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
