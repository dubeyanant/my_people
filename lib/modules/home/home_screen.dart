import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/controller/people_controller.dart';
import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';
import 'package:my_people/modules/home/widgets/empty_home.dart';
import 'package:my_people/modules/home/widgets/people_grid.dart';
import 'package:my_people/utility/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PeopleController _peopleController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // If PeopleController is not initialized yet
    if (!Get.isRegistered<PeopleController>()) {
      Get.put(PeopleController());
    }
    _peopleController = Get.find<PeopleController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.appName),
      actions: [
        Obx(() {
          if (_peopleController.people.isEmpty) return const SizedBox();

          return IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _peopleController.isSearchOpen.value
                  ? Icons.cancel_outlined
                  : Icons.search,
            ),
          );
        }),
      ],
    );
  }

  void _toggleSearch() {
    _peopleController.isSearchOpen.value =
        !_peopleController.isSearchOpen.value;
    if (!_peopleController.isSearchOpen.value) {
      _searchController.clear();
      _peopleController.filterPeople('');
      _searchFocusNode.unfocus();
    }
  }

  Widget _buildBody() {
    if (_peopleController.people.isEmpty) {
      return const EmptyHome();
    }

    return Column(
      children: [
        _buildSearchBar(),
        const Expanded(child: PeopleGrid()),
      ],
    );
  }

  Widget _buildSearchBar() {
    if (!_peopleController.isSearchOpen.value) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        focusNode: _searchFocusNode,
        autofocus: true,
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.searchBarHintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: _peopleController.filterPeople,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (_peopleController.people.isEmpty) {
        return const SizedBox.shrink();
      }

      return AnimatedPressButton(
        onPressed: () => showPersonDetailBottomSheet(context),
        child: Icon(
          Icons.add,
          size: 28,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    });
  }
}
