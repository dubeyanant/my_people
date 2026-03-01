import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'package:my_people/helpers/database_helper.dart';

class BackupHelper {
  static const String _backupExtension = '.myppl';
  static const String _databaseName =
      "myDatabase.db"; // Matching DatabaseHelper

  static Future<bool> createBackup() async {
    try {
      final dbPath = await _getDatabasePath();
      final File dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        return false;
      }
      final tempDir = await getTemporaryDirectory();
      final backupFileName =
          'mypeople_backup${DateTime.now().millisecondsSinceEpoch}$_backupExtension';
      final tempBackupFile = File('${tempDir.path}/$backupFileName');

      await dbFile.copy(tempBackupFile.path);

      final result = await SharePlus.instance.share(ShareParams(
        files: [XFile(tempBackupFile.path)],
        subject: 'MyPeople Backup',
      ));

      return result.status == ShareResultStatus.success;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['myppl'],
      );

      if (result == null || result.files.single.path == null) return false;

      final String backupPath = result.files.single.path!;
      final File backupFile = File(backupPath);
      final String dbPath = await _getDatabasePath();
      final File dbFile = File(dbPath);

      // 1. Safety backup of current DB
      final File safetyBackup = File('${dbFile.path}.bak');
      if (await dbFile.exists()) {
        await dbFile.copy(safetyBackup.path);
      }

      try {
        // 2. Close the open DB connection
        await DatabaseHelper.instance.close();

        // 3. Overwrite with backup file
        await backupFile.copy(dbFile.path);

        // 4. Validate the imported file
        final db = await openDatabase(dbFile.path);
        final check = await db.rawQuery('PRAGMA integrity_check');
        await db.close();
        if (check.first.values.first != 'ok') {
          throw Exception('Integrity check failed');
        }

        // 5. Re-initialize
        await DatabaseHelper.instance.database;
        await safetyBackup.delete();
        return true;
      } catch (e) {
        // Restore from safety backup
        if (await safetyBackup.exists()) {
          await safetyBackup.copy(dbFile.path);
          await safetyBackup.delete();
        }
        await DatabaseHelper.instance.database; // re-open original
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<String> _getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }
}
