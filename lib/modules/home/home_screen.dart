import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/modules/home/widgets/animated_press_button.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';
import 'package:my_people/modules/home/widgets/empty_home.dart';
import 'package:my_people/modules/home/widgets/people_grid.dart';
import 'package:my_people/utility/constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add listener to update focus state in controller
    _searchFocusNode.addListener(_onFocusChange);
  }

  // Method to handle focus changes
  void _onFocusChange() {
    ref
        .read(isHomeScreenSearchFocusedProvider.notifier)
        .updateFocus(_searchFocusNode.hasFocus);
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
        Consumer(builder: (context, ref, _) {
          final Widget child = ref.watch(peopleProvider).isEmpty
              ? const EmptyHome()
              : const PeopleGrid();
          return Padding(
            padding: const EdgeInsets.only(top: 140),
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
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white.withAlpha(0)],
              stops: const [0.8, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            height: gradientHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueAccent[700]!,
                  Colors.blue.withAlpha(180),
                  Colors.blue[200]!.withAlpha(40),
                ],
              ),
            ),
          ),
        ),
        // AppBar elements
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        // Always positioned Search Bar
        Positioned(
          top: 92,
          left: 16,
          right: 16,
          child: _buildSearchBar(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        focusNode: _searchFocusNode,
        autofocus: false,
        onTapOutside: (value) => _searchFocusNode.unfocus(),
        controller: _searchController,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          hintStyle: TextStyle(color: Colors.black54),
          hintText: AppStrings.personSearchBarHintText,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black54,
          ),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        onChanged: (value) =>
            ref.read(homeSearchQueryProvider.notifier).updateQuery(value),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer(builder: (context, ref, _) {
      if (ref.watch(peopleProvider).isEmpty) {
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
