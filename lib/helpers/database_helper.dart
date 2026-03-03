import 'dart:async';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import 'package:my_people/model/person.dart';
import 'package:my_people/model/person_info.dart';
import 'package:my_people/model/event.dart';

class DatabaseHelper {
  static const _databaseName = "myDatabase.db";
  static const _databaseVersion = 3;

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

  static const eventsTable = 'events';
  static const columnEventId = 'id';
  static const columnEventPersonUuid = 'personUuid';
  static const columnEventEmoji = 'emoji';
  static const columnEventTitle = 'title';
  static const columnEventDescription = 'description';
  static const columnEventDate = 'date';

  static const infosTable = 'infos';
  static const columnInfoId = 'id';
  static const columnInfoPersonUuid = 'personUuid';
  static const columnInfoText = 'text';
  static const columnInfoDate = 'date';

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

    await db.execute('''
      CREATE TABLE $eventsTable (
        $columnEventId TEXT PRIMARY KEY,
        $columnEventPersonUuid TEXT NOT NULL,
        $columnEventEmoji TEXT NOT NULL,
        $columnEventTitle TEXT NOT NULL,
        $columnEventDescription TEXT NOT NULL,
        $columnEventDate TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE $infosTable (
        $columnInfoId TEXT PRIMARY KEY,
        $columnInfoPersonUuid TEXT NOT NULL,
        $columnInfoText TEXT NOT NULL,
        $columnInfoDate TEXT
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
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE $eventsTable (
        $columnEventId TEXT PRIMARY KEY,
        $columnEventPersonUuid TEXT NOT NULL,
        $columnEventEmoji TEXT NOT NULL,
        $columnEventTitle TEXT NOT NULL,
        $columnEventDescription TEXT NOT NULL,
        $columnEventDate TEXT NOT NULL
      )
      ''');

      await db.execute('''
      CREATE TABLE $infosTable (
        $columnInfoId TEXT PRIMARY KEY,
        $columnInfoPersonUuid TEXT NOT NULL,
        $columnInfoText TEXT NOT NULL,
        $columnInfoDate TEXT
      )
      ''');

      // Data Migration: extract info from persons JSON to infos table
      List<Map<String, dynamic>> persons = await db.query(table);
      for (var personMap in persons) {
        String uuid = personMap[columnUuid] as String;
        String? infoJson = personMap[columnInfo] as String?;
        if (infoJson != null && infoJson.isNotEmpty) {
          try {
            final decodedList = jsonDecode(infoJson) as List;
            for (var element in decodedList) {
              PersonInfo parsedInfo;
              if (element is String) {
                parsedInfo =
                    PersonInfo(personUuid: uuid, text: element, date: null);
              } else if (element is Map<String, dynamic>) {
                parsedInfo =
                    PersonInfo.fromMap(element, defaultPersonUuid: uuid);
              } else {
                continue;
              }
              await db.insert(infosTable, parsedInfo.toMap());
            }
          } catch (e) {
            // ignore JSON errors if malformed
          }
        }
      }
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
    List<Map<String, dynamic>> personMaps = await db!.query(table);
    List<Map<String, dynamic>> eventMaps = await db.query(eventsTable);
    List<Map<String, dynamic>> infoMaps = await db.query(infosTable);

    List<Person> persons =
        personMaps.map((map) => Person.fromMap(map)).toList();
    List<Event> events = eventMaps.map((map) => Event.fromMap(map)).toList();
    List<PersonInfo> infos =
        infoMaps.map((map) => PersonInfo.fromMap(map)).toList();

    for (var person in persons) {
      person.events = events.where((e) => e.personUuid == person.uuid).toList();

      final dbInfos = infos.where((i) => i.personUuid == person.uuid).toList();
      if (dbInfos.isNotEmpty) {
        person.info = dbInfos;
        // Keep them sorted
        person.info.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });
      }
    }

    return persons;
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
    await db!.delete(eventsTable,
        where: '$columnEventPersonUuid = ?', whereArgs: [uuid]);
    await db.delete(infosTable,
        where: '$columnInfoPersonUuid = ?', whereArgs: [uuid]);
    return await db.delete(table, where: '$columnUuid = ?', whereArgs: [uuid]);
  }

  // Insert an Event object into the database
  Future<int> insertEvent(Event event) async {
    Database? db = await instance.database;
    return await db!.insert(eventsTable, event.toMap());
  }

  // Update an Event object
  Future<int> updateEvent(Event event) async {
    Database? db = await instance.database;
    return await db!.update(eventsTable, event.toMap(),
        where: '$columnEventId = ?', whereArgs: [event.id]);
  }

  // Delete an Event object
  Future<int> deleteEvent(String id) async {
    Database? db = await instance.database;
    return await db!
        .delete(eventsTable, where: '$columnEventId = ?', whereArgs: [id]);
  }

  // Insert an Info object into the database
  Future<int> insertInfo(PersonInfo info) async {
    Database? db = await instance.database;
    return await db!.insert(infosTable, info.toMap());
  }

  // Update an Info object
  Future<int> updateInfo(PersonInfo info) async {
    Database? db = await instance.database;
    return await db!.update(infosTable, info.toMap(),
        where: '$columnInfoId = ?', whereArgs: [info.id]);
  }

  // Delete an Info object
  Future<int> deleteInfo(String id) async {
    Database? db = await instance.database;
    return await db!
        .delete(infosTable, where: '$columnInfoId = ?', whereArgs: [id]);
  }
}
