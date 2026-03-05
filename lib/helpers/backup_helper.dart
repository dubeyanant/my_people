import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'package:my_people/helpers/database_helper.dart';
import 'package:archive/archive.dart';

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

      final archive = Archive();

      // Ensure database is completely written to disk
      final db = DatabaseHelper.instance;
      await db.close(); // Close allows WAL checkpoints to settle

      // Add database to archive
      final dbData = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile(_databaseName, dbData.length, dbData));

      // Fetch all people to find paths of profile images
      // Need to re-open DB temporarily
      final backupDb = await openDatabase(dbPath);
      final List<Map<String, dynamic>> persons =
          await backupDb.query('persons');
      await backupDb.close();

      for (var personMap in persons) {
        String? photoPath = personMap['photo'] as String?;
        if (photoPath != null && photoPath.isNotEmpty) {
          final photoFile = File(photoPath);
          if (await photoFile.exists()) {
            final String fileName = basename(photoPath);
            final photoData = await photoFile.readAsBytes();
            archive.addFile(
                ArchiveFile('images/$fileName', photoData.length, photoData));
          }
        }
      }

      // Encode archive
      final zipEncoder = ZipEncoder();
      final List<int> zipData = zipEncoder.encode(archive);

      final tempDir = await getTemporaryDirectory();
      final backupFileName =
          'mypeople_backup_${DateTime.now().millisecondsSinceEpoch}$_backupExtension';
      final tempBackupFile = File('${tempDir.path}/$backupFileName');

      await tempBackupFile.writeAsBytes(zipData);

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
      String backupPath = result.files.single.path!;

      final File backupFile = File(backupPath);
      if (!await backupFile.exists()) return false;

      // Unzip
      final bytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final dbPath = await _getDatabasePath();
      final appDir = await getApplicationDocumentsDirectory();

      // Close current connection
      await DatabaseHelper.instance.close();

      // Restore files
      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          if (file.name == _databaseName) {
            // Restore DB file
            final dbFile = File(dbPath);
            await dbFile.writeAsBytes(data, flush: true);
          } else if (file.name.startsWith('images/')) {
            // Restore images
            final fileName = basename(file.name);
            final imagePath = join(appDir.path, fileName);
            final imageFile = File(imagePath);
            await imageFile.writeAsBytes(data, flush: true);
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }
}
