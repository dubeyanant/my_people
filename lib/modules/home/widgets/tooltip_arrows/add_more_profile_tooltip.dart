import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/utility/constants.dart';

class AddMoreProfileTooltip extends StatelessWidget {
  const AddMoreProfileTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: -30,
              left: 148,
              child: SvgPicture.asset(
                'assets/arrows/arrow1.svg',
                height: 80,
                colorFilter: ColorFilter.mode(
                  Colors.grey[400] ?? Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(
              AppStrings.addMoreTooltip,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }
}
