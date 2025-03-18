// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:my_people/utility/constants.dart';
import 'package:my_people/utility/shared_preferences.dart';
import 'package:my_people/helpers/internet_connectivity_helper.dart';
import 'package:my_people/utility/debug_print.dart';

Future<Map<String, dynamic>> getLatestRelease() async {
  try {
    final response = await http.get(Uri.parse(
        'https://api.github.com/repos/dubeyanant/my_people/releases/latest'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      DebugPrint.log(
        'Failed to load latest release!\nStatus Code: ${response.statusCode}. Body: ${response.body}',
        color: DebugColor.red,
        tag: 'UpdateHelper',
      );
      throw Exception('Failed to load latest release');
    }
  } catch (e) {
    return {};
  }
}

Future<void> checkForUpdate(BuildContext context) async {
  DateTime? lastUpdateCheckDate = SharedPrefs.getLastUpdateCheckDate();
  DateTime now = DateTime.now();

  if (await isConnected() &&
      Platform.isAndroid &&
      (lastUpdateCheckDate == null ||
          now.difference(lastUpdateCheckDate).inDays >= 1)) {
    try {
      final latestRelease = await getLatestRelease();
      if (latestRelease.isNotEmpty) {
        final latestVersion = latestRelease['tag_name'];
        final String latestVersionWithoutV = latestVersion.substring(1);
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        bool isMajor = isMajorUpdate(currentVersion, latestVersionWithoutV);
        if (!isMajor) await SharedPrefs.setLastUpdateCheckDate(now);
        DebugPrint.log(
          'Current Version: $currentVersion\nLatest Version: $latestVersionWithoutV',
          tag: 'UpdateHelper',
          color: DebugColor.yellow,
        );
        if (latestVersionWithoutV != currentVersion && context.mounted) {
          showUpdateDialog(
            context,
            latestVersion,
            latestRelease['assets'][0]['browser_download_url'],
            isMajor,
          );
        }
      }
    } catch (e) {
      DebugPrint.log(
        'Error checking for updates: $e',
        color: DebugColor.red,
        tag: 'UpdateHelper',
      );
    }
  }
}

bool isMajorUpdate(String currentVersion, String latestVersion) {
  List<int> current = currentVersion.split('.').map(int.parse).toList();
  List<int> latest = latestVersion.split('.').map(int.parse).toList();
  return latest[0] > current[0]; // Compare major version number
}

void showUpdateDialog(
  BuildContext context,
  String latestVersion,
  String downloadUrl,
  bool isMajorUpdate,
) {
  showDialog(
    context: context,
    barrierDismissible: !isMajorUpdate,
    builder: (BuildContext context) {
      return PopScope(
        canPop: !isMajorUpdate,
        child: AlertDialog(
          title: Text(isMajorUpdate
              ? AppStrings.majorUpdateAvailable
              : AppStrings.updateAvailable),
          content: Text(isMajorUpdate
              ? 'A major update ($latestVersion) is available. You must update the app to continue using it.'
              : 'A new version ($latestVersion) is available. Please update the app.'),
          actions: <Widget>[
            if (!isMajorUpdate)
              TextButton(
                child: const Text(AppStrings.postpone),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: const Text(AppStrings.download),
              onPressed: () {
                Navigator.of(context).pop();
                downloadAndInstall(context, downloadUrl);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> downloadAndInstall(BuildContext context, String url) async {
  DebugPrint.log(
    'Download URL: $url',
    tag: 'UpdateHelper',
    color: DebugColor.yellow,
  );
  try {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/my_people_update.apk';

    Dio dio = Dio();
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(AppStrings.downloadingUpdate),
            content: DownloadProgress(dio, url, filePath),
          );
        },
      );
    }

    final File file = File(filePath);
    if (await file.exists()) {
      InstallPlugin.installApk(filePath, appId: "com.infiniteants.mypeople")
          .then((result) {
        DebugPrint.log(
          'Install result: $result',
          tag: 'UpdateHelper',
          color: DebugColor.yellow,
        );
      }).catchError((error) {
        DebugPrint.log('Install error: $error',
            color: DebugColor.red, tag: 'UpdateHelper');
      });
    } else {
      DebugPrint.log('Downloaded file does not exist',
          color: DebugColor.red, tag: 'UpdateHelper');
    }
  } catch (e) {
    DebugPrint.log('Download error: $e',
        color: DebugColor.red, tag: 'UpdateHelper');
  }
}

class DownloadProgress extends StatefulWidget {
  final Dio dio;
  final String url;
  final String filePath;

  const DownloadProgress(this.dio, this.url, this.filePath, {super.key});

  @override
  State<DownloadProgress> createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    startDownload();
  }

  void startDownload() async {
    try {
      await widget.dio.download(
        widget.url,
        widget.filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
            });
          }
        },
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      DebugPrint.log('Download error: $e',
          color: DebugColor.red, tag: 'UpdateHelper');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 20),
        Text('${(progress * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}
