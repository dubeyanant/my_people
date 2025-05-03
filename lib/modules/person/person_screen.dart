import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/person/add_info_bottomsheet.dart';
import 'package:my_people/modules/chat/chat_screen.dart';
import 'package:my_people/modules/person/widgets/add_new_detail_tool_tip.dart';
import 'package:my_people/modules/person/widgets/simple_header_clipper.dart';
import 'package:my_people/utility/constants.dart';

class PersonScreen extends StatefulWidget {
  final String id;
  const PersonScreen(this.id, {super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final double barHeight = 40;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final PeopleController pc = Get.put(PeopleController());
        final person =
            pc.people.firstWhere((element) => element.uuid == widget.id);
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
                value: AppStrings.edit,
                child: Text(AppStrings.edit),
              ),
              const PopupMenuItem<String>(
                value: AppStrings.delete,
                child: Text(AppStrings.delete),
              ),
            ],
          );

          // Handle the selected action from the popup menu
          if (result == AppStrings.delete) {
            pc.deletePersonInfo(person.uuid, infoItemIndex);
          } else if (result == AppStrings.edit) {
            if (context.mounted) {
              showAddInfoBottomSheet(
                context,
                widget.id,
                initialInfo: person.info[infoItemIndex],
                infoIndex: infoItemIndex,
              );
            }
          }
        }

        return Scaffold(
          body: Column(
            children: [
              Stack(
                children: [
                  // Background gradient container
                  ClipPath(
                    clipper: SimpleHeaderClipper(),
                    child: Container(
                      height: 260,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.lightBlueAccent,
                            Colors.blue,
                            Colors.blueAccent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // AppBar
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Text(
                          AppStrings.profile,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        if (person.info.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              pc.isSearchOpen.value
                                  ? Icons.cancel_outlined
                                  : Icons.search,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              pc.isSearchOpen.value = !pc.isSearchOpen.value;
                              if (!pc.isSearchOpen.value) {
                                searchController.clear();
                                searchFocusNode.unfocus();
                                searchQuery = '';
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  if (pc.isSearchOpen.value)
                    Positioned(
                      top: 76,
                      left: 4,
                      right: 4,
                      child: TextField(
                        focusNode: searchFocusNode,
                        autofocus: true,
                        controller: searchController,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.white),
                          prefixIconColor: Colors.white,
                          hintText: AppStrings.searchBarHintText,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => setState(() {
                          searchQuery = value.toLowerCase();
                        }),
                      ),
                    ),
                  // Profile image and name
                  Positioned(
                    top: 260 -
                        SimpleHeaderClipper.curveHeight -
                        SimpleHeaderClipper.curveDepth,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 12,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
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
                        Text(
                          person.name,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              person.info.isEmpty
                  ? AddNewDetailToolTip(person: person)
                  : Expanded(
                      child: ListView.builder(
                        itemCount: person.info.length,
                        itemBuilder: (context, index) {
                          if ((searchQuery.isEmpty ||
                                  person.info[index]
                                      .toLowerCase()
                                      .contains(searchQuery)) &&
                              person.info[index].isNotEmpty) {
                            return GestureDetector(
                              onLongPressStart: (details) {
                                showPopupMenu(
                                  context,
                                  index,
                                  details.globalPosition,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(60),
                                      blurRadius: 6.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      Colors.blue,
                                      Colors.blue[700]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                margin:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                width: double.maxFinite,
                                child: Text(
                                  person.info[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
            ],
          ),
          floatingActionButton: person.info.isEmpty ||
                  (person.info.length == 1 && person.info[0].isEmpty)
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (person.info.length >= 3)
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ChatScreen(person));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(60),
                                blurRadius: 6.0,
                                spreadRadius: 0.0,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.chat,
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.chat),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    AnimatedPressButton(
                      onPressed: () =>
                          showAddInfoBottomSheet(context, person.uuid),
                      child: const Icon(
                        Icons.add,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
