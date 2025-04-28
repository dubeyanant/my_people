import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/utility/constants.dart';

class ProfileTooltip extends StatelessWidget {
  const ProfileTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.2,
      right: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SvgPicture.asset(
                'assets/arrows/arrow3.svg',
                height: 100,
                colorFilter: ColorFilter.mode(
                  Colors.grey[400] ?? Colors.grey,
                  BlendMode.srcIn,
                ),
                // Flipping arrow horizontally to point left toward the profile
                matchTextDirection: true,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.profileTooltip,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
