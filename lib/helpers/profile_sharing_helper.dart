import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:my_people/helpers/database_helper.dart';
import 'package:my_people/model/person.dart';

class _EncryptArgs {
  final int versionCode;
  final Map<String, dynamic> personData;
  final Uint8List? photoBytes;

  _EncryptArgs(this.versionCode, this.personData, this.photoBytes);
}

Uint8List _encryptInIsolate(_EncryptArgs args) {
  String? photoBase64;
  if (args.photoBytes != null) {
    photoBase64 = base64Encode(args.photoBytes!);
  }

  final Map<String, dynamic> payload = {
    'versionCode': args.versionCode,
    'personData': args.personData,
    'photoBase64': photoBase64,
  };

  final jsonString = jsonEncode(payload);

  final key = enc.Key.fromUtf8('my_people_secure_profile_key_32!');
  final iv = enc.IV.fromLength(16);
  final encrypter = enc.Encrypter(enc.AES(key));

  return encrypter.encrypt(jsonString, iv: iv).bytes;
}

Map<String, dynamic> _decryptAndDecodeInIsolate(Uint8List bytes) {
  final key = enc.Key.fromUtf8('my_people_secure_profile_key_32!');
  final iv = enc.IV.fromLength(16);
  final encrypter = enc.Encrypter(enc.AES(key));

  final encrypted = enc.Encrypted(bytes);
  final decryptedJson = encrypter.decrypt(encrypted, iv: iv);
  final payload = jsonDecode(decryptedJson) as Map<String, dynamic>;

  Uint8List? photoBytes;
  if (payload['photoBase64'] != null) {
    photoBytes = base64Decode(payload['photoBase64']);
  }

  return {
    'versionCode': payload['versionCode'],
    'personData': payload['personData'],
    'photoBytes': photoBytes,
  };
}

class ProfileSharingHelper {
  static Future<void> shareProfile(Person person) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

    Uint8List? photoBytes;
    if (person.photo.isNotEmpty && !person.photo.startsWith('assets/')) {
      final photoFile = File(person.photo);
      if (await photoFile.exists()) {
        photoBytes = await photoFile.readAsBytes();
      }
    }

    final args = _EncryptArgs(
      currentVersionCode,
      person.toMap(),
      photoBytes,
    );

    // Run encryption on background isolate to avoid UI freezing
    final encryptedBytes = await compute(_encryptInIsolate, args);

    final String safeName =
        person.name.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
    final String fileName =
        '${safeName.isEmpty ? "profile" : safeName.replaceAll(" ", "")}.prf.myppl';

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');

    await tempFile.writeAsBytes(encryptedBytes);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(tempFile.path)],
      subject: 'My People Profile: ${person.name}',
    ));
  }

  static Future<Map<String, dynamic>?> getProfilePreview() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) {
      return null; // User canceled the picker
    }

    final String filePath = result.files.single.path!;
    if (!filePath.endsWith('.prf.myppl')) {
      throw Exception('Invalid file format. Please select a .prf.myppl file.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist.');
    }

    final bytes = await file.readAsBytes();

    Map<String, dynamic> payload;
    try {
      payload = await compute(_decryptAndDecodeInIsolate, bytes);
    } catch (e) {
      throw Exception(
          'Failed to decrypt profile data. The file might be corrupted or not a valid profile backup.');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
    final int payloadVersionCode = payload['versionCode'] ?? 0;

    if (currentVersionCode < payloadVersionCode) {
      throw Exception(
          'This profile requires a newer version of the My People app. Please update your app.');
    }

    final Map<String, dynamic> personMap = payload['personData'];
    return {
      'name': personMap['name'],
      'date': await file.lastModified(),
      'filePath': filePath
    };
  }

  // Returns the name of the imported person and the file date
  static Future<Map<String, dynamic>> importProfile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist.');
    }

    final bytes = await file.readAsBytes();

    Map<String, dynamic> payload;
    try {
      payload = await compute(_decryptAndDecodeInIsolate, bytes);
    } catch (e) {
      throw Exception(
          'Failed to decrypt profile data. The file might be corrupted or not a valid profile backup.');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
    final int payloadVersionCode = payload['versionCode'] ?? 0;

    if (currentVersionCode < payloadVersionCode) {
      throw Exception(
          'This profile requires a newer version of the My People app. Please update your app.');
    }

    final Map<String, dynamic> personMap = payload['personData'];

    // We want to add it as a new profile
    personMap.remove('uuid');
    final Person importedPerson = Person.fromMap(personMap);

    final Uint8List? photoBytes = payload['photoBytes'];
    if (photoBytes != null && photoBytes.isNotEmpty) {
      final docDir = await getApplicationDocumentsDirectory();
      final newPhotoFile = File(
          '${docDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await newPhotoFile.writeAsBytes(photoBytes);
      importedPerson.photo = newPhotoFile.path;
    }

    await DatabaseHelper.instance.insertPerson(importedPerson);

    return {'name': importedPerson.name, 'date': await file.lastModified()};
  }
}
