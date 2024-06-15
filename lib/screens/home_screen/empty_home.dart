import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/screens/person_bio_screen.dart';

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filled(
            onPressed: () => Get.to(() => const PersonBioScreen()),
            icon: const Icon(
              Icons.add,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add Your People!'),
        ],
      ),
    );
  }
}
