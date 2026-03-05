import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:my_people/helpers/database_helper.dart';
import 'package:my_people/model/person.dart';

class ProfileSharingHelper {
  static final _aesKeyStr = dotenv.env['AES_KEY']!;
  static final _hmacKeyStr = dotenv.env['HMAC_KEY']!;
  static final _magic = dotenv.env['MAGIC_KEY']!;

  static Uint8List _encrypt(String plainText) {
    final key = enc.Key.fromUtf8(_aesKeyStr);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.sic, padding: null));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  static String _decrypt(Uint8List bytes) {
    final key = enc.Key.fromUtf8(_aesKeyStr);
    final iv = enc.IV(bytes.sublist(0, 16));
    final cipherBytes = bytes.sublist(16);
    final encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.sic, padding: null));
    return encrypter.decrypt(enc.Encrypted(cipherBytes), iv: iv);
  }

  static String _computeHmac(Uint8List data) {
    final hmacKey = utf8.encode(_hmacKeyStr);
    final hmac = Hmac(sha256, hmacKey);
    return hmac.convert(data).toString();
  }

  static Future<void> _cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.prf.myppl')) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }

  static Future<void> shareProfile(Person person) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

    String? photoBase64;
    if (person.photo.isNotEmpty && !person.photo.startsWith('assets/')) {
      final photoFile = File(person.photo);
      if (await photoFile.exists()) {
        final photoBytes = await photoFile.readAsBytes();
        photoBase64 = base64Encode(photoBytes);
      }
    }

    final Map<String, dynamic> payload = {
      'magic': _magic,
      'versionCode': currentVersionCode,
      'personData': person.toSharingMap(),
      'photoBase64': photoBase64,
    };

    final jsonString = jsonEncode(payload);
    final encryptedBytes = _encrypt(jsonString);
    final hmacDigest = _computeHmac(encryptedBytes);

    final fileContent = '$hmacDigest\n${base64Encode(encryptedBytes)}';

    await _cleanupTempFiles();

    final String safeName =
        person.name.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName =
        '${safeName.isEmpty ? "profile" : safeName.replaceAll(" ", "")}_$timestamp.prf.myppl';

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');

    await tempFile.writeAsString(fileContent, flush: true);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(tempFile.path)],
      subject: 'My People Profile: ${person.name}',
    ));
  }

  static Map<String, dynamic> _readAndDecryptFile(String fileContent) {
    final lines = fileContent.trim().split(RegExp(r'\r?\n'));

    if (lines.length < 2) {
      throw Exception(
          'Invalid profile file format. The file appears to be corrupted.');
    }

    final storedHmac = lines[0].trim();
    final encryptedBase64 = lines.sublist(1).map((l) => l.trim()).join();

    final Uint8List encryptedBytes;
    try {
      encryptedBytes = base64Decode(encryptedBase64);
    } catch (e) {
      throw Exception('Invalid profile file. Could not decode file data.');
    }

    final computedHmac = _computeHmac(encryptedBytes);
    if (storedHmac != computedHmac) {
      throw Exception(
          'Integrity check failed. File corrupted or tampered with.');
    }

    final decryptedJson = _decrypt(encryptedBytes);

    final payload = jsonDecode(decryptedJson.trim().replaceAll('\uFEFF', ''))
        as Map<String, dynamic>;

    if (payload['magic'] != _magic) {
      throw Exception(
          'Invalid profile file. Not created by this version of My People.');
    }

    return payload;
  }

  static Future<Map<String, dynamic>?> getProfilePreview() async {
    await FilePicker.platform.clearTemporaryFiles();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) return null;

    final String filePath = result.files.single.path!;
    if (!filePath.endsWith('.prf.myppl')) {
      throw Exception('Invalid file format. Please select a .prf.myppl file.');
    }

    final file = File(filePath);
    if (!await file.exists()) throw Exception('File does not exist.');

    Map<String, dynamic> payload;
    try {
      payload = _readAndDecryptFile(await file.readAsString());
    } catch (e) {
      throw Exception('$e');
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
      'payload': payload,
    };
  }

  static Future<Map<String, dynamic>> importProfile(
      Map<String, dynamic> payload) async {
    final Map<String, dynamic> personMap = payload['personData'];

    final String newUuid = const Uuid().v4();
    personMap['uuid'] = newUuid;

    if (personMap['info'] != null) {
      final decodedList = jsonDecode(personMap['info']) as List;
      personMap['info'] = jsonEncode(decodedList.whereType<Map>().map((item) {
        return Map<String, dynamic>.from(item)
          ..['personUuid'] = newUuid
          ..remove('id');
      }).toList());
    }

    if (personMap['events'] != null) {
      final decodedList = jsonDecode(personMap['events']) as List;
      personMap['events'] = jsonEncode(decodedList.whereType<Map>().map((item) {
        return Map<String, dynamic>.from(item)
          ..['personUuid'] = newUuid
          ..remove('id');
      }).toList());
    }

    final Person importedPerson = Person.fromMap(personMap);

    final String? photoBase64 = payload['photoBase64'];
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      final Uint8List photoBytes = base64Decode(photoBase64);
      final docDir = await getApplicationDocumentsDirectory();
      final newPhotoFile = File(
          '${docDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await newPhotoFile.writeAsBytes(photoBytes);
      importedPerson.photo = newPhotoFile.path;
    }

    await DatabaseHelper.instance.insertPerson(importedPerson);

    for (var infoItem in importedPerson.info) {
      await DatabaseHelper.instance.insertInfo(infoItem);
    }
    for (var eventItem in importedPerson.events) {
      await DatabaseHelper.instance.insertEvent(eventItem);
    }

    return {'name': importedPerson.name};
  }
}
