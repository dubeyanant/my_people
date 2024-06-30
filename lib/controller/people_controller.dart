import 'package:get/get.dart';

import 'package:my_people/helpers/database_helper.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/utility/debug_print.dart';

class PeopleController extends GetxController {
  RxList<Person> people = <Person>[].obs;
  RxList<Person> filteredPeople = <Person>[].obs;
  RxBool isSearchOpen = false.obs;
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void onInit() {
    super.onInit();
    fetchPeople();
  }

  // Initialize filteredPeople with all people at startup
  void fetchPeople() async {
    List<Person> fetchedPeoples = await dbHelper.fetchPersons();
    people.assignAll(fetchedPeoples);
    filteredPeople.assignAll(fetchedPeoples);
    DebugPrint.log(
      'People fetched: ${filteredPeople.length}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
    for (var element in filteredPeople) {
      DebugPrint.log(
        'Name: ${element.name}\tUUID: ${element.uuid}',
        color: DebugColor.green,
        tag: 'PeopleController',
      );
    }
  }

  // Method to add a person to the list
  void addPerson(Person person) async {
    await dbHelper.insertPerson(person);
    DebugPrint.log(
      'Person Added: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
    fetchPeople();
  }

  // Method to update a person in the list
  void updatePerson(Person oldPerson, String newName, String newPhoto) async {
    final index = people.indexWhere((person) => person.uuid == oldPerson.uuid);
    if (index != -1) {
      people[index].name = newName;
      people[index].photo = newPhoto;
      DebugPrint.log(
        'Person Updated: ${oldPerson.name}\nNew Name: $newName\nNew Photo: $newPhoto',
        color: DebugColor.green,
        tag: 'PeopleController',
      );
      await dbHelper.updatePerson(people[index]);
      fetchPeople();
    }
  }

  // Method to delete a person from the list
  void deletePerson(Person person) async {
    await dbHelper.deletePerson(person.uuid);
    DebugPrint.log(
      'Person Deleted: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
    fetchPeople();
  }

  // Method to add info to a person
  void addInfoToPerson(String uuid, String info) async {
    final index = people.indexWhere((person) => person.uuid == uuid);
    if (index != -1) {
      people[index].info.insert(0, info);
      await dbHelper.updatePerson(people[index]);
      people.refresh();
      DebugPrint.log(
        'Info Added to ${people[index].name}: $info',
        color: DebugColor.magenta,
        tag: 'PeopleController',
      );
      fetchPeople();
    }
  }

  // Method to update info of a person
  void updatePersonInfo(String uuid, String newInfo, int index) async {
    final person = people.firstWhere((person) => person.uuid == uuid);
    if (index != -1) {
      person.info[index] = newInfo;
      await dbHelper.updatePerson(person);
      people.refresh();
      DebugPrint.log(
        'Person Info Updated: ${person.name}\nNew Info: ${person.info[index]}',
        color: DebugColor.magenta,
        tag: 'PeopleController',
      );
      fetchPeople();
    }
  }

  // Method to delete info of a person
  void deletePersonInfo(String uuid, int infoItemIndex) async {
    final index = people.indexWhere((person) => person.uuid == uuid);
    if (index != -1) {
      people[index].info.removeAt(infoItemIndex);
      await dbHelper.updatePerson(people[index]);
      people.refresh();
      DebugPrint.log(
        'Person Info Deleted: ${people[index].name}\nInfo Index: $infoItemIndex',
        color: DebugColor.magenta,
        tag: 'PeopleController',
      );
      fetchPeople();
    }
  }

  // Method to filter people based on the search query
  void filterPeople(String query) {
    if (query.isEmpty) {
      filteredPeople.assignAll(people);
    } else {
      filteredPeople.assignAll(
        people
            .where((person) =>
                person.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }
}
