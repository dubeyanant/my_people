import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:my_people/utility/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeState extends _$ThemeState {
  @override
  String build() {
    return SharedPrefs.getThemeState();
  }

  void setTheme(String theme) {
    state = theme;
    SharedPrefs.setThemeState(theme);
  }
}
