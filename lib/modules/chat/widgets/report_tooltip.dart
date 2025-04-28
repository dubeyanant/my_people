import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

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
                'Hold the message to report',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
              SvgPicture.asset(
                'assets/arrows/underline1.svg',
                height: 30,
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
