import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/helpers/update_helper.dart';
import 'package:my_people/screens/person_detail_bottomsheet.dart';
import 'package:my_people/screens/home_screen/empty_home.dart';
import 'package:my_people/screens/home_screen/people_grid.dart';
import 'package:my_people/utility/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      checkForUpdate(context);
    }
  }

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
                  const Expanded(
                    child: PeopleGrid(),
                  ),
                ],
              ),
        floatingActionButton: pc.people.isEmpty
            ? null
            : FloatingActionButton(
                tooltip: AppStrings.addPerson,
                onPressed: () => showPersonDetailBottomSheet(context),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
