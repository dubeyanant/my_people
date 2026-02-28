import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:my_people/model/person_info.dart';
import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/helpers/database_helper.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/utility/debug_print.dart';

part 'people_provider.g.dart';

@riverpod
class People extends _$People {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  List<Person> build() {
    _fetchPeople();
    return [];
  }

  Future<void> _fetchPeople() async {
    final fetchedPeoples = await _dbHelper.fetchPersons();
    state = fetchedPeoples;

    DebugPrint.log(
      'People fetched: ${state.length}',
      color: DebugColor.green,
      tag: 'PeopleProvider',
    );
    for (var element in state) {
      DebugPrint.log(
        'Name: ${element.name}\tUUID: ${element.uuid}\nInfo: ${element.info}',
        color: DebugColor.green,
        tag: 'PeopleProvider',
      );
    }
  }

  Future<void> addPerson(Person person) async {
    await _dbHelper.insertPerson(person);
    DebugPrint.log(
      'Person Added: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleProvider',
    );
    AnalyticsHelper.trackFeatureUsage('add_person');
    _fetchPeople();
  }

  Future<void> updatePerson(
      Person oldPerson, String newName, String newPhoto) async {
    final index = state.indexWhere((person) => person.uuid == oldPerson.uuid);
    if (index != -1) {
      // Create a copy of the person to update
      final updatedPerson = Person(
        uuid: oldPerson.uuid,
        name: newName,
        photo: newPhoto,
        info: List.from(oldPerson.info),
      );

      DebugPrint.log(
        'Person Updated: ${oldPerson.name}\nNew Name: $newName\nNew Photo: $newPhoto',
        color: DebugColor.green,
        tag: 'PeopleProvider',
      );
      await _dbHelper.updatePerson(updatedPerson);
      AnalyticsHelper.trackFeatureUsage('update_person');
      _fetchPeople();
    }
  }

  Future<void> deletePerson(Person person) async {
    await _dbHelper.deletePerson(person.uuid);
    DebugPrint.log(
      'Person Deleted: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleProvider',
    );
    AnalyticsHelper.trackFeatureUsage('delete_person');
    _fetchPeople();
  }

  Future<void> addInfoToPerson(String uuid, PersonInfo info) async {
    final person = state.firstWhere((p) => p.uuid == uuid);
    final updatedInfo = List<PersonInfo>.from(person.info)..insert(0, info);

    final updatedPerson = Person(
      uuid: person.uuid,
      name: person.name,
      photo: person.photo,
      info: updatedInfo,
    );

    await _dbHelper.updatePerson(updatedPerson);
    DebugPrint.log(
      'Info Added to ${person.name}: ${info.text}',
      color: DebugColor.magenta,
      tag: 'PeopleProvider',
    );
    AnalyticsHelper.trackFeatureUsage('add_info');
    _fetchPeople();
  }

  Future<void> updatePersonInfo(
      String uuid, PersonInfo newInfo, int index) async {
    final person = state.firstWhere((p) => p.uuid == uuid);
    if (index != -1 && index < person.info.length) {
      final updatedInfo = List<PersonInfo>.from(person.info)..[index] = newInfo;

      final updatedPerson = Person(
        uuid: person.uuid,
        name: person.name,
        photo: person.photo,
        info: updatedInfo,
      );

      await _dbHelper.updatePerson(updatedPerson);
      DebugPrint.log(
        'Person Info Updated: ${person.name}\nNew Info: ${newInfo.text}',
        color: DebugColor.magenta,
        tag: 'PeopleProvider',
      );
      AnalyticsHelper.trackFeatureUsage('update_info');
      _fetchPeople();
    }
  }

  Future<void> deletePersonInfo(String uuid, int infoItemIndex) async {
    final person = state.firstWhere((p) => p.uuid == uuid);
    if (infoItemIndex != -1 && infoItemIndex < person.info.length) {
      final updatedInfo = List<PersonInfo>.from(person.info)
        ..removeAt(infoItemIndex);

      final updatedPerson = Person(
        uuid: person.uuid,
        name: person.name,
        photo: person.photo,
        info: updatedInfo,
      );

      await _dbHelper.updatePerson(updatedPerson);
      DebugPrint.log(
        'Person Info Deleted: ${person.name}\nInfo Index: $infoItemIndex',
        color: DebugColor.magenta,
        tag: 'PeopleProvider',
      );
      AnalyticsHelper.trackFeatureUsage('delete_info');
      _fetchPeople();
    }
  }
}

@riverpod
class HomeSearchQuery extends _$HomeSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
class IsHomeScreenSearchFocused extends _$IsHomeScreenSearchFocused {
  @override
  bool build() => false;

  void updateFocus(bool isFocused) {
    state = isFocused;
  }
}

@riverpod
List<Person> filteredPeople(Ref ref) {
  final people = ref.watch(peopleProvider);
  final query = ref.watch(homeSearchQueryProvider);

  if (query.isEmpty) {
    return people;
  } else {
    return people
        .where(
            (person) => person.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
