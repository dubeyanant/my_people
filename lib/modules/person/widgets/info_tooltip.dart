import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/utility/constants.dart';

class InfoTooltip extends StatelessWidget {
  const InfoTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SvgPicture.asset(
              'assets/arrows/arrow4.svg',
              height: 100,
              colorFilter: ColorFilter.mode(
                Colors.grey[400] ?? Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.infoTooltip,
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
