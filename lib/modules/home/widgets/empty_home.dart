import 'package:flutter/material.dart';

import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/home/widgets/tooltip_arrows/add_profile_tooltip.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedPressButton(
            onPressed: () => showPersonDetailBottomSheet(context),
            child: Icon(
              Icons.add,
              size: 28,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          AddProfileTooltip(),
        ],
      ),
    );
  }
}
