import 'dart:async';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:my_people/model/person.dart';

class DatabaseHelper {
  static const _databaseName = "myDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'persons';

  static const columnUuid = 'uuid';
  static const columnName = 'name';
  static const columnPhoto = 'photo';
  static const columnInfo = 'info';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnUuid TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnPhoto TEXT NOT NULL,
        $columnInfo TEXT
      )
      ''');
  }

  // Insert a Person object into the database
  Future<int> insertPerson(Person person) async {
    Database? db = await instance.database;
    return await db!.insert(table, person.toMap());
  }

  // Fetch all Person objects from the database
  Future<List<Person>> fetchPersons() async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> maps = await db!.query(table);
    return List.generate(maps.length, (i) {
      return Person(
        uuid: maps[i][columnUuid],
        name: maps[i][columnName],
        photo: maps[i][columnPhoto],
        info: maps[i][columnInfo]
            .split(','), // Assuming info is stored as comma-separated string
      );
    });
  }

  // Update a Person object
  Future<int> updatePerson(Person person) async {
    Database? db = await instance.database;
    return await db!.update(table, person.toMap(),
        where: '$columnUuid = ?', whereArgs: [person.uuid]);
  }

  // Delete a Person object
  Future<int> deletePerson(String uuid) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnUuid = ?', whereArgs: [uuid]);
  }
}
