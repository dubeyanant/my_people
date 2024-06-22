import 'package:get/get.dart';

import 'package:my_people/model/person.dart';
import 'package:my_people/utility/debug_print.dart';

class PeopleController extends GetxController {
  RxList<Person> people = <Person>[].obs;
  RxList<Person> filteredPeople = <Person>[].obs;
  RxBool isSearchOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    people.addAll([
      Person(
        name: 'John Doe',
        photo: 'assets/default1.webp',
        info: ['Age: 25', 'Occupation: Developer'],
      ),
      Person(
        name: 'Jane Doe',
        photo: 'assets/default2.webp',
        info: ['Age: 23', 'Occupation: Designer'],
      ),
      Person(
        name: 'Alice',
        photo: 'assets/default3.webp',
        info: ['Age: 30', 'Occupation: Manager'],
      ),
      Person(
        name: 'Bob',
        photo: 'assets/default4.webp',
        info: ['Age: 28', 'Occupation: Engineer'],
      ),
    ]);
    fetchPeople();
  }

  // Initialize filteredPeople with all people at startup
  void fetchPeople() {
    filteredPeople.assignAll(people);
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
  void addPerson(Person person) {
    people.add(person);
    DebugPrint.log(
      'Person Added: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
    fetchPeople();
  }

  // Method to update a person in the list
  void updatePerson(Person oldPerson, String newName, String newPhoto) {
    final index = people.indexWhere((person) => person.uuid == oldPerson.uuid);
    if (index != -1) {
      people[index].name = newName;
      people[index].photo = newPhoto;
      DebugPrint.log(
        'Person Updated: ${oldPerson.name}\nNew Name: $newName\nNew Photo: $newPhoto',
        color: DebugColor.green,
        tag: 'PeopleController',
      );
      fetchPeople();
    }
  }

  // Method to delete a person from the list
  void deletePerson(Person person) {
    people.remove(person);
    DebugPrint.log(
      'Person Deleted: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
    fetchPeople();
  }

  // Method to add info to a person
  void addInfoToPerson(String uuid, String info) {
    final index = people.indexWhere((person) => person.uuid == uuid);
    if (index != -1) {
      people[index].info.insert(0, info);
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
  void updatePersonInfo(String uuid, String newInfo, int index) {
    final person = people.firstWhere((person) => person.uuid == uuid);
    if (index != -1) {
      person.info[index] = newInfo;
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
  void deletePersonInfo(String uuid, int infoItemIndex) {
    final index = people.indexWhere((person) => person.uuid == uuid);
    if (index != -1) {
      people[index].info.removeAt(infoItemIndex);
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
