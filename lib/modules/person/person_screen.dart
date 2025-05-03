import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/person/add_info_bottomsheet.dart';
import 'package:my_people/modules/chat/chat_screen.dart';
import 'package:my_people/modules/person/widgets/add_more_details_tooltip.dart';
import 'package:my_people/modules/person/widgets/add_new_detail_tool_tip.dart';
import 'package:my_people/modules/person/widgets/info_tooltip.dart';
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
  final PeopleController pc = Get.put(PeopleController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final person =
          pc.people.firstWhere((element) => element.uuid == widget.id);
      return Scaffold(
        body: Column(
          children: [
            _buildHeader(person),
            _buildBody(person),
          ],
        ),
        floatingActionButton: _buildFloatingActionButtons(person),
      );
    });
  }

  Widget _buildHeader(Person person) {
    final isFile = File(person.photo).existsSync();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background gradient container
        ClipPath(
          clipper: SimpleHeaderClipper(),
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueAccent[700]!,
                  Colors.blue,
                  Colors.blue[200]!,
                ],
              ),
            ),
          ),
        ),
        // AppBar
        _buildAppBar(person),
        // Search Field (when search is open)
        if (pc.isSearchOpen.value) _buildSearchField(),
        // Profile image and name
        _buildProfileInfo(person, isFile),
      ],
    );
  }

  Widget _buildAppBar(Person person) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            AppStrings.profile,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              pc.isSearchOpen.value ? Icons.cancel_outlined : Icons.search,
              color: person.info.isNotEmpty ? Colors.white : Colors.transparent,
            ),
            onPressed: person.info.isNotEmpty ? _toggleSearch : null,
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    pc.isSearchOpen.value = !pc.isSearchOpen.value;
    if (!pc.isSearchOpen.value) {
      searchController.clear();
      searchFocusNode.unfocus();
      setState(() => searchQuery = '');
    }
  }

  Widget _buildSearchField() {
    return Positioned(
      top: 76,
      left: 4,
      right: 4,
      child: TextField(
        focusNode: searchFocusNode,
        autofocus: true,
        controller: searchController,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintStyle: TextStyle(color: Colors.white),
          prefixIconColor: Colors.white,
          hintText: AppStrings.searchBarHintText,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() {
          searchQuery = value.toLowerCase();
        }),
      ),
    );
  }

  Widget _buildProfileInfo(Person person, bool isFile) {
    return Positioned(
      top: 260 -
          SimpleHeaderClipper.curveHeight -
          SimpleHeaderClipper.curveDepth,
      left: 0,
      right: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 12),
          Text(
            person.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.deepOrangeAccent,
              height: 1,
            ),
          ),
          // Text(
          //   AppStrings.generating,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     color: Colors.grey,
          //     fontSize: 12,
          //     height: 1.4,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildBody(Person person) {
    return person.info.isEmpty
        ? AddNewDetailToolTip(person: person)
        : Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: person.info.length,
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                  itemBuilder: (context, index) {
                    if ((searchQuery.isEmpty ||
                            person.info[index]
                                .toLowerCase()
                                .contains(searchQuery)) &&
                        person.info[index].isNotEmpty) {
                      return _buildInfoItem(context, person, index);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (person.info.length == 1 && !pc.isSearchOpen.value) ...[
                  InfoTooltip(),
                  AddMoreDetailsTooltip(),
                ],
              ],
            ),
          );
  }

  Widget _buildInfoItem(BuildContext context, Person person, int index) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showPopupMenu(context, person, index, details.globalPosition);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xff9DCEB7),
              Color(0xff339989),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   AppStrings.title,
            //   style: const TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w600,
            //     color: Colors.white,
            //   ),
            // ),
            Text(
              person.info[index],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPopupMenu(BuildContext context, Person person,
      int infoItemIndex, Offset offset) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + 1,
        offset.dy + 1,
      ),
      items: const [
        PopupMenuItem<String>(
          value: AppStrings.edit,
          child: Text(AppStrings.edit),
        ),
        PopupMenuItem<String>(
          value: AppStrings.delete,
          child: Text(AppStrings.delete),
        ),
      ],
    );

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

  Widget? _buildFloatingActionButtons(Person person) {
    if (person.info.isEmpty ||
        (person.info.length == 1 && person.info[0].isEmpty)) {
      return null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (person.info.length >= 3) _buildChatButton(person),
        const SizedBox(height: 16),
        Tooltip(
          message: AppStrings.addMoreTooltip,
          verticalOffset: -50,
          preferBelow: false,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: TextStyle(
            color: Colors.grey[800],
            fontSize: 12,
          ),
          child: AnimatedPressButton(
            onPressed: () => showAddInfoBottomSheet(context, person.uuid),
            child: const Icon(
              Icons.add,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton(Person person) {
    return GestureDetector(
      onTap: () => Get.to(() => ChatScreen(person)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.chat,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
