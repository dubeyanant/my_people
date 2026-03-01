// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(People)
final peopleProvider = PeopleProvider._();

final class PeopleProvider extends $NotifierProvider<People, List<Person>> {
  PeopleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'peopleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$peopleHash();

  @$internal
  @override
  People create() => People();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Person> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Person>>(value),
    );
  }
}

String _$peopleHash() => r'e4f93e8115cebcddaba1aea135d2fb2894e83845';

abstract class _$People extends $Notifier<List<Person>> {
  List<Person> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Person>, List<Person>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Person>, List<Person>>,
        List<Person>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HomeSearchQuery)
final homeSearchQueryProvider = HomeSearchQueryProvider._();

final class HomeSearchQueryProvider
    extends $NotifierProvider<HomeSearchQuery, String> {
  HomeSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeSearchQueryHash();

  @$internal
  @override
  HomeSearchQuery create() => HomeSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$homeSearchQueryHash() => r'ed7784cd9b2a6e32f6afb46ac739bb4bd0bf593c';

abstract class _$HomeSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(IsHomeScreenSearchFocused)
final isHomeScreenSearchFocusedProvider = IsHomeScreenSearchFocusedProvider._();

final class IsHomeScreenSearchFocusedProvider
    extends $NotifierProvider<IsHomeScreenSearchFocused, bool> {
  IsHomeScreenSearchFocusedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isHomeScreenSearchFocusedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isHomeScreenSearchFocusedHash();

  @$internal
  @override
  IsHomeScreenSearchFocused create() => IsHomeScreenSearchFocused();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isHomeScreenSearchFocusedHash() =>
    r'ad4664d2bfe8db4708570c8df57d4d84b121a132';

abstract class _$IsHomeScreenSearchFocused extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredPeople)
final filteredPeopleProvider = FilteredPeopleProvider._();

final class FilteredPeopleProvider
    extends $FunctionalProvider<List<Person>, List<Person>, List<Person>>
    with $Provider<List<Person>> {
  FilteredPeopleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredPeopleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredPeopleHash();

  @$internal
  @override
  $ProviderElement<List<Person>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Person> create(Ref ref) {
    return filteredPeople(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Person> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Person>>(value),
    );
  }
}

String _$filteredPeopleHash() => r'4a095ca7096ad0de5305c436e00ece4e5a36dfc7';
