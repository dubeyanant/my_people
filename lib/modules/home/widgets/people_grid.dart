import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/modules/person/person_screen.dart';
import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/modules/home/widgets/tooltip_arrows/add_more_profile_tooltip.dart';

class PeopleGrid extends ConsumerWidget {
  const PeopleGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPeople = ref.watch(filteredPeopleProvider);
    final isSearchFocused = ref.watch(isHomeScreenSearchFocusedProvider);

    // Check if there's exactly one person in the list
    final bool showTooltip = filteredPeople.length == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          GridView.count(
            // Making the aspect ratio more elongated (height-wise)
            childAspectRatio: 4 / 5,
            padding: const EdgeInsets.only(top: 16),
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 16, // Space between columns
            mainAxisSpacing: 24, // Space between rows
            children: filteredPeople.map((person) {
              final isFile = File(person.photo).existsSync();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonScreen(person.uuid),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: isFile
                            ? Image.file(
                                File(person.photo),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                person.photo,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Theme.of(context).cardColor,
                        child: Text(
                          person.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // Only show tooltips if there's one person AND search isn't focused
          if (showTooltip && !isSearchFocused) ...[
            AddMoreProfileTooltip(),
          ],
        ],
      ),
    );
  }
}
