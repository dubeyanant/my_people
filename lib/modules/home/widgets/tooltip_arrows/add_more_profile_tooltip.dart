import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/utility/constants.dart';

class AddMoreProfileTooltip extends StatelessWidget {
  const AddMoreProfileTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                AppStrings.addMoreTooltip,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
              Positioned(
                top: 12,
                left: -36,
                child: SvgPicture.asset(
                  'assets/arrows/arrow1.svg',
                  height: 80,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface.withAlpha(100),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
