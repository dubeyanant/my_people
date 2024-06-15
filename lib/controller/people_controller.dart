import 'package:get/get.dart';

import 'package:my_people/model/person.dart';

class PeopleController extends GetxController {
  final List<Person> people = <Person>[].obs;

  void addPerson(Person person) {
    people.add(person);
  }

  void deletePerson(Person person) {
    people.remove(person);
  }
}
