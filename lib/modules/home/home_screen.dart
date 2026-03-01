import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/modules/home/widgets/tooltip_arrows/add_profile_tooltip.dart';
import 'package:my_people/providers/people_provider.dart';
import 'package:my_people/widgets/radial_menu_button.dart';
import 'package:my_people/modules/person/person_detail_bottomsheet.dart';
import 'package:my_people/modules/home/widgets/people_grid.dart';
import 'package:my_people/utility/constants.dart';
import 'package:my_people/utility/app_theme.dart';

import 'package:my_people/modules/settings/settings_screen.dart';
import 'package:my_people/helpers/biometric_helper.dart';
import 'package:my_people/utility/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Add listener to update focus state in controller
    _searchFocusNode.addListener(_onFocusChange);
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool success = await BiometricHelper.checkAuthIfEnabled();
    if (mounted) {
      setState(() {
        _isAuthenticated = success;
      });
    }
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
    if (!_isAuthenticated && SharedPrefs.getBiometricEnabled()) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64),
              const SizedBox(height: 16),
              const Text('App Locked', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkBiometrics,
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildGradientHeader(),
        Consumer(builder: (context, ref, _) {
          final Widget child = ref.watch(peopleProvider).isEmpty
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: AddProfileTooltip(),
                ))
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
    final headerGradient =
        Theme.of(context).extension<HeaderGradientTheme>()?.colors ??
            [Colors.blueAccent, Colors.blue];

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
                  headerGradient[0],
                  headerGradient.length > 1
                      ? headerGradient[1]
                      : headerGradient[0],
                  Theme.of(context).scaffoldBackgroundColor,
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
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
              ),
            ),
          ),
        ),
        // Always positioned Search Bar
        ref.watch(peopleProvider).isEmpty
            ? const SizedBox.shrink()
            : Positioned(
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
        color: Theme.of(context).colorScheme.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        focusNode: _searchFocusNode,
        autofocus: false,
        onTapOutside: (value) => _searchFocusNode.unfocus(),
        controller: _searchController,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150)),
          hintText: AppStrings.personSearchBarHintText,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
        ),
        onChanged: (value) =>
            ref.read(homeSearchQueryProvider.notifier).updateQuery(value),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return RadialMenuButton(
      options: [
        RadialMenuOption(
          label: 'Create',
          icon: Icons.add_rounded,
          degrees: 90,
          onSelected: () => showPersonDetailBottomSheet(context),
        ),
        RadialMenuOption(
          label: 'Settings',
          icon: Icons.settings_rounded,
          degrees: 0,
          onSelected: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        RadialMenuOption(
          label: 'Search',
          icon: Icons.search_rounded,
          degrees: 180,
          onSelected: () {
            _searchFocusNode.requestFocus();
          },
        ),
      ],
    );
  }
}
