import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/widgets/radial_menu_button.dart';
import 'package:my_people/modules/person/add_info_bottomsheet.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';
import 'package:my_people/modules/chat/chat_screen.dart';
import 'package:my_people/modules/person/widgets/add_more_details_tooltip.dart';
import 'package:my_people/modules/person/widgets/add_new_detail_tool_tip.dart';
import 'package:my_people/modules/person/widgets/info_tooltip.dart';
import 'package:my_people/utility/constants.dart';
import 'package:my_people/utility/app_theme.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(Person person) {
    final isFile = File(person.photo).existsSync();
    final screenHeight = MediaQuery.of(context).size.height;
    final gradientHeight = screenHeight * 0.3;
    final headerGradient =
        Theme.of(context).extension<HeaderGradientTheme>()?.colors ??
            [Colors.blueAccent, Colors.blue];

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
                  headerGradient[0],
                  headerGradient.length > 1
                      ? headerGradient[1]
                      : headerGradient[0],
                  Theme.of(context).scaffoldBackgroundColor,
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
      right: 16,
      child: SizedBox(
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(200),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  focusNode: searchFocusNode,
                  onTapOutside: (value) => searchFocusNode.unfocus(),
                  controller: searchController,
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16),
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150)),
                    hintText: AppStrings.noteSearchBarHintText,
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150)),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  onChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(Person person, bool isFile) {
    return Positioned(
      top: 116,
      left: 0,
      right: 0,
      child: Column(
        spacing: 16,
        children: [
          CircleAvatar(
            radius: 60,
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
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppStrings.infoTimeline,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: person.info.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      bool shouldDisplay = (searchQuery.isEmpty ||
                              person.info[index].text
                                  .toLowerCase()
                                  .contains(searchQuery)) &&
                          person.info[index].text.isNotEmpty;

                      if (shouldDisplay) {
                        final infoItemWidget =
                            _buildTimelineItem(context, person, index);
                        bool showTooltipsBelow =
                            person.info.length == 1 && searchQuery.isEmpty;

                        if (showTooltipsBelow) {
                          return Column(
                            children: [
                              infoItemWidget,
                              const SizedBox(height: 16),
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
                ),
              ],
            ),
          );
  }

  Widget _buildTimelineItem(BuildContext context, Person person, int index) {
    final bool isFirst = index == 0;
    final bool isLast = index == person.info.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 48,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Line above dot
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isFirst
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.primary.withAlpha(80),
                    ),
                  ),
                ),
                // Dot
                TimelineIndicator(isFilled: true),
                // Line below dot
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isLast
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.primary.withAlpha(80),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Card
          Expanded(
            child: GestureDetector(
              onLongPressStart: (details) {
                _showPopupMenu(context, person, index, details.globalPosition);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.fromLTRB(0, 6, 16, 6),
                child: _buildInfoContent(context, person.info[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContent(BuildContext context, info) {
    final dateObj = info.date;
    final dateStr = dateObj != null
        ? '${_getMonthName(dateObj.month)} ${dateObj.day}, ${dateObj.year}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dateStr != null) ...[
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          info.text,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
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
    return RadialMenuButton(
      options: [
        RadialMenuOption(
          label: 'Create',
          icon: Icons.add_rounded,
          degrees: 90,
          onSelected: () => showAddInfoBottomSheet(context, person.uuid),
        ),
        RadialMenuOption(
          label: 'Chat',
          icon: Icons.chat_rounded,
          degrees: 0,
          onSelected: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen(person)),
            );
          },
        ),
        RadialMenuOption(
          label: 'Edit',
          icon: Icons.edit_rounded,
          degrees: 45,
          onSelected: () {
            if (context.mounted) {
              showPersonDetailBottomSheet(context, personToEdit: person);
            }
          },
        ),
        RadialMenuOption(
          label: 'Search',
          icon: Icons.search_rounded,
          degrees: 180,
          onSelected: () {
            searchFocusNode.requestFocus();
          },
        ),
      ],
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
