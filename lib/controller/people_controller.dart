import 'package:get/get.dart';

import 'package:my_people/model/person.dart';
import 'package:my_people/utility/debug_print.dart';

class PeopleController extends GetxController {
  RxList<Person> people = <Person>[].obs;
  RxList<Person> filteredPeople = <Person>[].obs;
  RxBool isSearchOpen = false.obs;

  @override
  void onInit() {
    fetchPeople();
    super.onInit();
  }

  void fetchPeople() {
    // Initialize filteredPeople with all people at startup
    filteredPeople.assignAll(people);
    DebugPrint.log(
      'People fetched: ${filteredPeople.length}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
  }

  // Method to add a person to the list
  void addPerson(Person person) {
    people.add(person);
    DebugPrint.log(
      'Person Added: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
  }

  // Method to delete a person from the list
  void deletePerson(Person person) {
    people.remove(person);
    DebugPrint.log(
      'Person Deleted: ${person.name}',
      color: DebugColor.green,
      tag: 'PeopleController',
    );
  }

  // Method to update a person in the list
  void updatePerson(Person oldPerson, String newName, String newPhoto) {
    final index = people.indexWhere((person) => person == oldPerson);
    if (index != -1) {
      people[index] = Person(
        name: newName,
        photo: newPhoto,
        info: oldPerson.info,
      );
      DebugPrint.log(
        'Person Updated: ${oldPerson.name}\nNew Name: $newName\nNew Photo: $newPhoto',
        color: DebugColor.green,
        tag: 'PeopleController',
      );
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
