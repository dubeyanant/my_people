import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:my_people/utility/constants.dart';

class ReportTooltip extends StatelessWidget {
  const ReportTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      right: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.toReport,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
              SvgPicture.asset(
                'assets/arrows/underline1.svg',
                height: 30,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface.withAlpha(100),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
