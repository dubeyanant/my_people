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
    // Add listener to update focus state in controller
    _searchFocusNode.addListener(_onFocusChange);
  }

  // Method to handle focus changes
  void _onFocusChange() {
    _peopleController.isHomeScreenSearchFocused.value =
        _searchFocusNode.hasFocus;
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildGradientHeader(),
        Obx(() {
          final Widget child = _peopleController.people.isEmpty
              ? const EmptyHome()
              : const PeopleGrid();
          return Padding(
            padding: EdgeInsets.only(top: 136),
            child: child,
          );
        }),
      ],
    );
  }

  Widget _buildGradientHeader() {
    final screenHeight = MediaQuery.of(context).size.height;
    final gradientHeight = screenHeight * 0.3;

    return Stack(
      children: [
        // ShaderMask for smooth blending
        ShaderMask(
          shaderCallback: (Rect bounds) {
            // Create a vertical gradient mask from opaque white to transparent white
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white.withAlpha(0)],
              stops: const [
                0.85,
                1.0
              ], // Start fading near the bottom (85% mark)
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn, // Apply the mask
          child: Container(
            height: gradientHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueAccent[400]!,
                  Colors.blue.withAlpha(160),
                  Colors.blue[200]!.withAlpha(40),
                ],
              ),
            ),
          ),
        ),
        // AppBar elements
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        // Always positioned Search Bar
        Positioned(
          top: 88,
          left: 16,
          right: 16,
          child: _buildSearchBar(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Material(
      color: Colors.transparent,
      child: TextField(
        focusNode: _searchFocusNode,
        autofocus: false,
        onTapOutside: (value) => _searchFocusNode.unfocus(),
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.personSearchBarHintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).canvasColor.withAlpha(240),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
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
