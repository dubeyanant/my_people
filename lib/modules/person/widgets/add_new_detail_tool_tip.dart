import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/model/person.dart';
import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/person/add_info_bottomsheet.dart';
import 'package:my_people/utility/constants.dart';

class AddNewDetailToolTip extends StatelessWidget {
  const AddNewDetailToolTip({
    super.key,
    required this.person,
  });

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        AnimatedPressButton(
          onPressed: () => showAddInfoBottomSheet(context, person.uuid),
          child: const Icon(
            Icons.add,
            size: 28,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 4),
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
          AppStrings.personScreenTagline,
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
