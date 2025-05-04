import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';
import 'package:my_people/modules/home/widgets/empty_home.dart';
import 'package:my_people/modules/home/widgets/people_grid.dart';
import 'package:my_people/utility/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PeopleController pc = Get.put(PeopleController());
    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          actions: [
            if (pc.people.isNotEmpty)
              IconButton(
                onPressed: () {
                  pc.isSearchOpen.value = !pc.isSearchOpen.value;
                  if (!pc.isSearchOpen.value) {
                    searchController.clear();
                    pc.filterPeople('');
                    searchFocusNode.unfocus();
                  }
                },
                icon: Icon(
                  pc.isSearchOpen.value ? Icons.cancel_outlined : Icons.search,
                ),
              ),
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
                        focusNode: searchFocusNode,
                        autofocus: true,
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: AppStrings.searchBarHintText,
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
                  const Expanded(child: PeopleGrid()),
                ],
              ),
        floatingActionButton: pc.people.isEmpty
            ? null
            : AnimatedPressButton(
                onPressed: () => showPersonDetailBottomSheet(context),
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
