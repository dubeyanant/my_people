import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/modules/person/widgets/profile_details_panel.dart';
import 'package:my_people/widgets/radial_menu_button.dart';
import 'package:my_people/modules/chat/chat_screen.dart';
import 'package:my_people/helpers/profile_sharing_helper.dart';
import 'package:my_people/model/event.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/modules/person/add_info_bottomsheet.dart';
import 'package:my_people/modules/person/add_event_bottomsheet.dart';
import 'package:my_people/modules/person/person_profile_setup_screen.dart';
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
  bool showAllEvents = false;

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
    return Padding(
      padding: const EdgeInsets.only(top: 116),
      child: SizedBox(
        width: double.infinity,
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
            ProfileDetailsPanel(person: person),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Person person) {
    bool hasInfo = person.info.isNotEmpty;
    bool hasEvents = person.events.isNotEmpty;

    if (!hasInfo && !hasEvents) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 140),
          child: Text(
            AppStrings.personScreenTagline,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasEvents) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (person.events.length > 3)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showAllEvents = !showAllEvents;
                          });
                        },
                        child: Text(
                          showAllEvents ? 'Show Less' : 'Show More',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildEventsList(person),
            ],
            if (hasInfo) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.notes,
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: person.info.length,
                itemBuilder: (context, index) {
                  bool shouldDisplay = (searchQuery.isEmpty ||
                          person.info[index].text
                              .toLowerCase()
                              .contains(searchQuery)) &&
                      person.info[index].text.isNotEmpty;

                  if (shouldDisplay) {
                    return _buildTimelineItem(context, person, index);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(Person person) {
    if (person.events.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final futureEvents =
        person.events.where((e) => e.date.isAfter(now)).toList();
    final pastEvents = person.events
        .where((e) => e.date.isBefore(now) || e.date.isAtSameMomentAs(now))
        .toList();

    // Sort future events ascending (nearest first)
    futureEvents.sort((a, b) => a.date.compareTo(b.date));
    // Sort past events descending (most recent first)
    pastEvents.sort((a, b) => b.date.compareTo(a.date));

    final sortedEvents = [...futureEvents, ...pastEvents];
    final displayEvents =
        showAllEvents ? sortedEvents : sortedEvents.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: displayEvents.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == displayEvents.length - 1;
          final bool isPast = event.date.isBefore(DateTime.now());

          return GestureDetector(
            onLongPressStart: (details) {
              _showEventPopupMenu(
                  context, person, event, details.globalPosition);
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timeline column
                  SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(20),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(50),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(event.emoji,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(50),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 16,
                        bottom: isLast ? 0 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: isPast ? 0.4 : 1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_getMonthName(event.date.month)} ${event.date.day}, ${event.date.year}\n${event.date.hour > 12 ? event.date.hour - 12 : (event.date.hour == 0 ? 12 : event.date.hour)}:${event.date.minute.toString().padLeft(2, '0')} ${event.date.hour >= 12 ? 'PM' : 'AM'}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: isPast ? 0.7 : 1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (event.description.isNotEmpty)
                            Text(
                              event.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(isPast ? 120 : 200),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Person person, int index) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showPopupMenu(context, person, index, details.globalPosition);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: double.infinity,
        child: _buildInfoContent(context, person.info[index]),
      ),
    );
  }

  Widget _buildInfoContent(BuildContext context, info) {
    final dateObj = info.date;

    String? dateStr;

    if (dateObj != null) {
      final now = DateTime.now();

      // Remove time portion for accurate date-only comparison
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateObj.year, dateObj.month, dateObj.day);

      final difference = today.difference(messageDate).inDays;

      if (difference == 0) {
        dateStr = "Today";
      } else if (difference == 1) {
        dateStr = "Yesterday";
      } else {
        dateStr =
            '${_getMonthName(dateObj.month)} ${dateObj.day}, ${dateObj.year}';
      }
    }

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

  Future<void> _showEventPopupMenu(
      BuildContext context, Person person, Event event, Offset offset) async {
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
          .deletePersonEvent(person.uuid, event.id);
    } else if (result == AppStrings.edit) {
      if (context.mounted) {
        showAddEventBottomSheet(
          context,
          person.uuid,
          initialEvent: event,
        );
      }
    }
  }

  Widget? _buildFloatingActionButtons(Person person) {
    return RadialMenuButton(
      options: [
        RadialMenuOption(
          label: 'Note',
          icon: Icons.add_rounded,
          degrees: 90,
          onSelected: () => showAddInfoBottomSheet(context, person.uuid),
        ),
        RadialMenuOption(
          label: 'Chat',
          icon: Icons.chat_rounded,
          degrees: 45,
          enabled: person.info.length > 3,
          onSelected: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen(person)),
            );
          },
        ),
        RadialMenuOption(
          label: 'Profile',
          icon: Icons.edit_rounded,
          degrees: 0,
          onSelected: () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PersonProfileSetupScreen(person: person)),
              );
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
        RadialMenuOption(
          label: 'Share',
          icon: Icons.share,
          degrees: 225,
          onSelected: () => ProfileSharingHelper.shareProfile(person),
        ),
        RadialMenuOption(
          label: 'Event',
          icon: Icons.event,
          degrees: 135,
          onSelected: () => showAddEventBottomSheet(context, person.uuid),
        ),
      ],
    );
  }
}
