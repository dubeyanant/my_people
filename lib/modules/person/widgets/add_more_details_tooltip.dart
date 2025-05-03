import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:my_people/utility/constants.dart';

class AddMoreDetailsTooltip extends StatelessWidget {
  const AddMoreDetailsTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 16,
                top: 16,
                child: Text(
                  AppStrings.addMoreTooltip2,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SvgPicture.asset(
                'assets/arrows/circle1.svg',
                height: 80,
                colorFilter: ColorFilter.mode(
                  Colors.grey[400] ?? Colors.grey,
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
