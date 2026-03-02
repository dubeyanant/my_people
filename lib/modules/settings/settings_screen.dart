import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:my_people/utility/debug_print.dart';
import 'package:my_people/utility/app_theme.dart';
import 'package:my_people/utility/shared_preferences.dart';
import 'package:my_people/providers/theme_provider.dart';
import 'package:my_people/helpers/backup_helper.dart';
import 'package:my_people/helpers/biometric_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBiometricEnabled = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _isBiometricEnabled = SharedPrefs.getBiometricEnabled();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  void _handleThemeChange(String? newValue) {
    if (newValue != null) {
      ref.read(themeStateProvider.notifier).setTheme(newValue);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final canAuth = await BiometricHelper.hasBiometrics();
      if (!canAuth) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Biometrics not available on this device')),
          );
        }
        return;
      }
      final authenticated = await BiometricHelper.authenticate();
      if (!authenticated) return;
    }

    setState(() {
      _isBiometricEnabled = value;
    });
    SharedPrefs.setBiometricEnabled(value);
  }

  Future<void> _handleBackup() async {
    final success = await BackupHelper.createBackup();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? 'Backup saved successfully'
                : 'Failed to save backup')),
      );
    }
  }

  Future<void> _handleRestore() async {
    final success = await BackupHelper.importBackup();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Backup imported successfully. Please restart the app.'
              : 'Failed to import backup'),
        ),
      );
    }
  }

  Future<void> _sendFeatureRequest() async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'contact@anantdubey.com',
        query: 'subject=Feature Request - My People App',
      );
      await launchUrl(emailLaunchUri);
    } catch (e) {
      DebugPrint.log(e.toString());
    }
  }

  Future<void> _sendBugReport() async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'contact@anantdubey.com',
        query: 'subject=Bug Report - My People App',
      );
      await launchUrl(emailLaunchUri);
    } catch (e) {
      DebugPrint.log(e.toString());
    }
  }

  Future<void> _openPrivacyPolicy() async {
    try {
      final Uri url = Uri.parse('https://www.anantdubey.com/privacy-policy');
      await launchUrl(url);
    } catch (e) {
      DebugPrint.log(e.toString());
    }
  }

  Future<void> _rateApp() async {
    try {
      final Uri url = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.infiniteants.mypeople');
      await launchUrl(url);
    } catch (e) {
      DebugPrint.log(e.toString());
    }
  }

  Future<void> _shareApp() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: "My People App",
          uri: Uri.parse(
              'https://play.google.com/store/apps/details?id=com.infiniteants.mypeople'),
        ),
      );
    } catch (e) {
      DebugPrint.log(e.toString());
    }
  }

  Future<void> _donation() async {
    try {
      final Uri url = Uri.parse('https://www.buymeacoffee.com/aanant');
      await launchUrl(url);
    } catch (e) {
      DebugPrint.log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  Theme.of(context).extension<HeaderGradientTheme>()?.colors ??
                      [Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Selection
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: themeState,
              onChanged: _handleThemeChange,
              items: const [
                DropdownMenuItem(value: 'dynamic', child: Text('Dynamic')),
                DropdownMenuItem(value: 'morning', child: Text('Morning')),
                DropdownMenuItem(value: 'noon', child: Text('Noon')),
                DropdownMenuItem(value: 'evening', child: Text('Evening')),
                DropdownMenuItem(value: 'night', child: Text('Night')),
              ],
            ),
          ),
          const Divider(),

          // Backup options
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Create Backup'),
            subtitle: const Text('Save your data as .myppl file'),
            onTap: _handleBackup,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Import Backup'),
            subtitle: const Text('Restore data from .myppl file'),
            onTap: _handleRestore,
          ),
          const Divider(),

          // Biometrics
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Enable Biometrics'),
            value: _isBiometricEnabled,
            onChanged: _toggleBiometric,
          ),
          const Divider(),

          // Links
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            onTap: _rateApp,
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            onTap: _shareApp,
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Feature Request'),
            onTap: _sendFeatureRequest,
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Bug Report'),
            onTap: _sendBugReport,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: _openPrivacyPolicy,
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.coffee),
            title: const Text('Buy Me A Coffee'),
            subtitle: const Text(
                'Support future updates and keep this project alive'),
            onTap: _donation,
          ),

          // Personal Note
          const ListTile(
            leading: Icon(Icons.note),
            title: Text('Developer\'s Note'),
            subtitle: Text(
                "My People started as a personal need. I wanted a single place to remember even little things about the people who matter to me.\n\nNo tracking. No ads. No cloud. Everything stays on your device, period.\n\nI didn't cut corners on privacy because I use this app myself and I wouldn't want it any other way.\n\nIf you have ideas, feedback, or just want to say hi, I'd love to hear from you.\n\nBuilt with ❤️ by Anant Dubey."),
          ),

          // Version
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: Text(_appVersion),
          ),
        ],
      ),
    );
  }
}
