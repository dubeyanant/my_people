import 'package:get/get.dart';

import 'package:my_people/model/person.dart';

class PeopleController extends GetxController {
  final RxList<Person> people = <Person>[].obs;

  // Method to add a person to the list
  void addPerson(Person person) {
    people.add(person);
  }

  // Method to delete a person from the list
  void deletePerson(Person person) {
    people.remove(person);
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
    }
  }
}
