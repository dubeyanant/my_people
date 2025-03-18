import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/screens/person_detail_bottomsheet.dart';
import 'package:my_people/utility/constants.dart';

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filled(
            onPressed: () => showPersonDetailBottomSheet(context),
            icon: const Icon(
              Icons.add,
              size: 32,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, bottom: 4),
            child: SvgPicture.asset(
              'assets/arrow1.svg',
              height: 100,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
          ),
          const Text(
            AppStrings.homeScreenTagline,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
