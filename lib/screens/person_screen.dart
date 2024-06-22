import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/screens/add_info_bottomsheet.dart';
import 'package:my_people/utility/constants.dart';

class PersonScreen extends StatelessWidget {
  final String id;
  const PersonScreen(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PeopleController pc = Get.put(PeopleController());
      final person = pc.people.firstWhere((element) => element.uuid == id);
      final isFile = File(person.photo).existsSync();
      final TextEditingController searchController = TextEditingController();
      final FocusNode searchFocusNode = FocusNode();

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
          pc.deletePersonInfo(person.uuid, infoItemIndex);
        } else if (result == 'edit') {
          if (context.mounted) {
            showAddInfoBottomSheet(
              context,
              id,
              initialInfo: person.info[infoItemIndex],
              infoIndex: infoItemIndex,
            );
          }
        }
      }

      return PopScope(
        onPopInvoked: (didPop) {
          Future.delayed(const Duration(milliseconds: 10), () {
            pc.isSearchOpen.value = false;
          });
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(person.name),
            actions: [
              if (person.info.isNotEmpty)
                IconButton(
                  icon: Icon(
                    pc.isSearchOpen.value
                        ? Icons.cancel_outlined
                        : Icons.search,
                  ),
                  onPressed: () {
                    pc.isSearchOpen.value = !pc.isSearchOpen.value;
                    if (!pc.isSearchOpen.value) {
                      searchController.clear();
                      searchFocusNode.unfocus();
                    }
                  },
                ),
            ],
          ),
          body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (pc.isSearchOpen.value)
                  TextField(
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
                    onChanged: (value) {},
                  ),
                const SizedBox(height: 16),
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
                            width: 1,
                            height: 60,
                          ),
                          IconButton.filled(
                            onPressed: () {
                              showAddInfoBottomSheet(context, person.uuid);
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(AppStrings.personScreenTagline),
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
                                  width: 1,
                                  height: 60,
                                ),
                                GestureDetector(
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
                  tooltip: AppStrings.addDetail,
                  onPressed: () => showAddInfoBottomSheet(context, person.uuid),
                  child: const Icon(Icons.add),
                ),
        ),
      );
    });
  }
}
