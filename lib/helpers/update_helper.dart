// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

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
  if (await isConnected()) {
    try {
      final latestRelease = await getLatestRelease();
      if (latestRelease.isNotEmpty) {
        final latestVersion = latestRelease['tag_name'];
        final String latestVersionWithoutV = latestVersion.substring(1);

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        DebugPrint.log(
          'Current Version: $currentVersion\nLatest Version: $latestVersionWithoutV',
          color: DebugColor.yellow,
          tag: 'UpdateHelper',
        );
        if (latestVersionWithoutV != currentVersion && context.mounted) {
          showUpdateDialog(context, latestVersion,
              latestRelease['assets'][0]['browser_download_url']);
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

void showUpdateDialog(
    BuildContext context, String latestVersion, String downloadUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Update Available'),
        content: Text(
            'A new version ($latestVersion) is available. Please update the app.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Download'),
            onPressed: () {
              Navigator.of(context).pop();
              downloadAndInstall(context, downloadUrl);
            },
          ),
        ],
      );
    },
  );
}

Future<void> downloadAndInstall(BuildContext context, String url) async {
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
            title: const Text('Downloading Update'),
            content: DownloadProgress(dio, url, filePath),
          );
        },
      );
    }

    InstallPlugin.installApk(filePath, appId: 'com.example.my_people')
        .then((result) {
      DebugPrint.log('Install result: $result', tag: 'UpdateHelper');
    }).catchError((error) {
      DebugPrint.log('Install error: $error',
          color: DebugColor.red, tag: 'UpdateHelper');
    });
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
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      DebugPrint.log('Download error: $e',
          color: DebugColor.red, tag: 'UpdateHelper');
      if (context.mounted) {
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
