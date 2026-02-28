import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/person/add_info_bottomsheet.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';
import 'package:my_people/modules/chat/chat_screen.dart';
import 'package:my_people/modules/person/widgets/add_more_details_tooltip.dart';
import 'package:my_people/modules/person/widgets/add_new_detail_tool_tip.dart';
import 'package:my_people/modules/person/widgets/info_tooltip.dart';
import 'package:my_people/utility/constants.dart';

class PersonScreen extends ConsumerStatefulWidget {
  final String id;
  const PersonScreen(this.id, {super.key});

  @override
  ConsumerState<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends ConsumerState<PersonScreen> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(peopleProvider);
    final person = people.firstWhere((element) => element.uuid == widget.id,
        orElse: () => Person(name: 'Unknown', photo: '', info: []));

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(person),
          _buildBody(person),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(person),
    );
  }

  Widget _buildHeader(Person person) {
    final isFile = File(person.photo).existsSync();
    final screenHeight = MediaQuery.of(context).size.height;
    final gradientHeight = screenHeight * 0.3;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background gradient container
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white.withAlpha(0)],
              stops: const [0.8, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            height: gradientHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueAccent[700]!,
                  Colors.blue.withAlpha(180),
                  Colors.blue[200]!.withAlpha(40),
                ],
              ),
            ),
          ),
        ),
        // AppBar
        _buildAppBar(person),
        // Profile image and name
        _buildProfileInfo(person, isFile),
      ],
    );
  }

  Widget _buildAppBar(Person person) {
    return Positioned(
      top: 48,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  focusNode: searchFocusNode,
                  controller: searchController,
                  cursorColor: Colors.black87,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  maxLines: 1,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    hintStyle: TextStyle(color: Colors.black54),
                    hintText: AppStrings.noteSearchBarHintText,
                    prefixIcon: Icon(Icons.search, color: Colors.black54),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  onChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                if (context.mounted) {
                  showPersonDetailBottomSheet(context, personToEdit: person);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(Person person, bool isFile) {
    return Positioned(
      top: 116,
      left: 16,
      child: Row(
        spacing: 16,
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
          Text(
            person.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Person person) {
    return person.info.isEmpty
        ? Expanded(child: AddNewDetailToolTip(person: person))
        : Expanded(
            child: ListView.builder(
              itemCount: person.info.length,
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              itemBuilder: (context, index) {
                bool shouldDisplay = (searchQuery.isEmpty ||
                        person.info[index].text
                            .toLowerCase()
                            .contains(searchQuery)) &&
                    person.info[index].text.isNotEmpty;

                if (shouldDisplay) {
                  final infoItemWidget = _buildInfoItem(context, person, index);
                  bool showTooltipsBelow =
                      person.info.length == 1 && searchQuery.isEmpty;

                  if (showTooltipsBelow) {
                    return Column(
                      spacing: 16,
                      children: [
                        infoItemWidget,
                        InfoTooltip(),
                        AddMoreDetailsTooltip(),
                      ],
                    );
                  } else {
                    return infoItemWidget;
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          );
  }

  Widget _buildInfoItem(BuildContext context, Person person, int index) {
    final info = person.info[index];
    final dateObj = info.date;
    final dateStr = dateObj != null
        ? '${_getMonthName(dateObj.month)} ${dateObj.day}, ${dateObj.year}'
        : null;

    return GestureDetector(
      onLongPressStart: (details) {
        _showPopupMenu(context, person, index, details.globalPosition);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9BB9B),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateStr != null) ...[
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              info.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
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
      ref
          .read(peopleProvider.notifier)
          .deletePersonInfo(person.uuid, infoItemIndex);
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
        (person.info.length == 1 && person.info[0].text.isEmpty)) {
      return null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (person.info.length >= 3) _buildChatButton(person),
        const SizedBox(height: 16),
        AnimatedPressButton(
          onPressed: () => showAddInfoBottomSheet(context, person.uuid),
          child: Icon(
            Icons.add,
            size: 28,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton(Person person) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatScreen(person))),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.chat,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.chat,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineIndicator extends StatelessWidget {
  const TimelineIndicator({
    super.key,
    required this.isFilled,
  });

  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isFilled ? Theme.of(context).colorScheme.primary : null,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
