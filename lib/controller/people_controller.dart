import 'package:get/get.dart';

import 'package:my_people/model/person.dart';

class PeopleController extends GetxController {
  final List<Person> people = <Person>[].obs;

  // @override
  // void onInit() {
  //   people.addAll([
  //     Person(
  //       name: 'John Doe',
  //       photo: 'assets/portrait.jpg',
  //       info: [],
  //     ),
  //     Person(
  //       name: 'Jane Doe',
  //       photo: 'assets/portrait.jpg',
  //       info: [],
  //     ),
  //     Person(
  //       name: 'John Smith',
  //       photo: 'assets/portrait.jpg',
  //       info: [],
  //     ),
  //     Person(
  //       name: 'Jane Smith',
  //       photo: 'assets/portrait.jpg',
  //       info: [],
  //     ),
  //   ]);

  //   super.onInit();
  // }
}
