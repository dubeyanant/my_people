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
    final TextEditingController searchController = TextEditingController();

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text('My People'),
          actions: [
            if (pc.people.isNotEmpty)
              IconButton(
                onPressed: () {
                  pc.isSearchOpen.value = !pc.isSearchOpen.value;
                },
                icon: Icon(
                  pc.isSearchOpen.value ? Icons.cancel_outlined : Icons.search,
                ),
              ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        ),
        body: pc.people.isEmpty
            ? const EmptyHome()
            : Column(
                children: [
                  if (pc.isSearchOpen.value)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          pc.filterPeople(value);
                        },
                      ),
                    ),
                  const Expanded(
                    child: PeopleGrid(),
                  ),
                ],
              ),
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
