import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/view/screens/home_screen/widgets/animated_press_button.dart';
import 'package:my_people/view/screens/person_detail_bottomsheet.dart';
import 'package:my_people/utility/constants.dart';

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
            child: const Icon(
              Icons.add,
              size: 28,
              color: Colors.white,
            ),
          ),
          _EmptyHomeArrow(),
        ],
      ),
    );
  }
}

class _EmptyHomeArrow extends StatelessWidget {
  const _EmptyHomeArrow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 8, bottom: 8),
          child: SvgPicture.asset(
            'assets/arrows/arrow2.svg',
            height: 120,
            colorFilter: ColorFilter.mode(
              Colors.grey[400] ?? Colors.grey,
              BlendMode.srcIn,
            ),
          ),
        ),
        Text(
          AppStrings.homeScreenTagline,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
