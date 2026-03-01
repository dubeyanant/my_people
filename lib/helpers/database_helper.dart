import 'dart:async';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:my_people/model/person.dart';

class DatabaseHelper {
  static const _databaseName = "myDatabase.db";
  static const _databaseVersion = 2;

  static const table = 'persons';

  static const columnUuid = 'uuid';
  static const columnName = 'name';
  static const columnPhoto = 'photo';
  static const columnInfo = 'info';
  static const columnBirthday = 'birthday';
  static const columnRelationshipType = 'relationshipType';
  static const columnSocialInstagram = 'socialInstagram';
  static const columnSocialTwitter = 'socialTwitter';
  static const columnSocialLinkedIn = 'socialLinkedIn';
  static const columnOccupation = 'occupation';
  static const columnInterests = 'interests';
  static const columnDietaryRestrictions = 'dietaryRestrictions';
  static const columnIntrovertExtrovert = 'introvertExtrovert';
  static const columnRelationshipStatus = 'relationshipStatus';

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

  Future<void> close() async {
    final db = await database;
    await db?.close();
    _database = null;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnUuid TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnPhoto TEXT NOT NULL,
        $columnInfo TEXT,
        $columnBirthday TEXT,
        $columnRelationshipType TEXT,
        $columnSocialInstagram TEXT,
        $columnSocialTwitter TEXT,
        $columnSocialLinkedIn TEXT,
        $columnOccupation TEXT,
        $columnInterests TEXT,
        $columnDietaryRestrictions TEXT,
        $columnIntrovertExtrovert TEXT,
        $columnRelationshipStatus TEXT
      )
      ''');
  }

  // SQL code to upgrade the database table
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnBirthday TEXT');
      await db.execute(
          'ALTER TABLE $table ADD COLUMN $columnRelationshipType TEXT');
      await db
          .execute('ALTER TABLE $table ADD COLUMN $columnSocialInstagram TEXT');
      await db
          .execute('ALTER TABLE $table ADD COLUMN $columnSocialTwitter TEXT');
      await db
          .execute('ALTER TABLE $table ADD COLUMN $columnSocialLinkedIn TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnOccupation TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnInterests TEXT');
      await db.execute(
          'ALTER TABLE $table ADD COLUMN $columnDietaryRestrictions TEXT');
      await db.execute(
          'ALTER TABLE $table ADD COLUMN $columnIntrovertExtrovert TEXT');
      await db.execute(
          'ALTER TABLE $table ADD COLUMN $columnRelationshipStatus TEXT');
    }
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
    return maps.map((map) => Person.fromMap(map)).toList();
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
