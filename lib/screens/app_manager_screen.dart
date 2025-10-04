import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:url_launcher/url_launcher.dart';

class AppManagerScreen extends StatefulWidget {
  const AppManagerScreen({super.key});
  @override
  State<AppManagerScreen> createState() => _AppManagerScreenState();
}

class _AppManagerScreenState extends State<AppManagerScreen> {
  List<AppInfo> _allApps = [];
  List<AppInfo> _displayedApps = [];
  bool _showSystemApps = false;
  bool _isHibernating = false;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  void _loadApps() {
    setState(() {
      _displayedApps = [];
    });
    InstalledApps.getInstalledApps(true, true).then((apps) {
      setState(() {
        apps.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
        _allApps = apps;
        _filterApps();
      });
    });
  }

  void _filterApps() {
    setState(() {
      if (_showSystemApps) {
        _displayedApps = _allApps;
      } else {
        _displayedApps =
            _allApps.where((app) => app.isSystemApp == false).toList();
      }
    });
  }

  void _showOptionsDialog(AppInfo app) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('App Info'),
              onTap: () {
                Navigator.pop(context);
                InstalledApps.openSettings(app.packageName!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop_circle_outlined),
              title: const Text('Force Stop'),
              onTap: () {
                Navigator.pop(context);
                _forceStopApp(app);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services_rounded),
              title: const Text('Clear Cache'),
              onTap: () {
                Navigator.pop(context);
                _clearCache(app);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearCache(AppInfo app) async {
    // This is the platform-standard way to do it.
    // It opens the app's specific settings page.
    final Uri url = Uri.parse('package:${app.packageName}');
    await launchUrl(
      Uri.parse("package:${app.packageName}"),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _forceStopApp(AppInfo app) async {
    bool isServiceEnabled =
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    if (!isServiceEnabled) {
      _showPermissionDialog();
      return;
    }
    await FlutterAccessibilityService.forceStopPackage(app.packageName!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attempted to force stop ${app.name}')),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "To use this feature, you must enable the Accessibility Service for System Suite. This allows the app to perform the 'Force Stop' action."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Go to Settings"),
            onPressed: () {
              Navigator.of(context).pop();
              FlutterAccessibilityService.requestAccessibilityPermission();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _hibernateAllApps() async {
    bool isServiceEnabled =
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    if (!isServiceEnabled) {
      _showPermissionDialog();
      return;
    }

    setState(() {
      _isHibernating = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting hibernation...')),
    );

    // Get the list of non-system apps
    List<AppInfo> appsToHibernate =
        _allApps.where((app) => app.isSystemApp == false).toList();

    for (final app in appsToHibernate) {
      if (app.packageName != null) {
        // We add a small delay to give the system time to process each action
        await Future.delayed(const Duration(milliseconds: 500));
        await FlutterAccessibilityService.forceStopPackage(app.packageName!);
      }
    }

    setState(() {
      _isHibernating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hibernation process completed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Manager"),
        actions: [
          Switch(
            value: _showSystemApps,
            onChanged: (value) {
              setState(() {
                _showSystemApps = value;
                _filterApps();
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text("System"),
          )
        ],
      ),
      body: _allApps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _displayedApps.length,
              itemBuilder: (context, index) {
                AppInfo app = _displayedApps[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: app.icon != null && app.icon!.isNotEmpty
                        ? Image.memory(app.icon!)
                        : const Icon(Icons.android),
                  ),
                  title: Text(app.name ?? "Unknown App"),
                  subtitle: Text(app.packageName ?? "Unknown Package"),
                  onTap: () => _showOptionsDialog(app),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isHibernating ? null : _hibernateAllApps,
        label: _isHibernating
            ? const Text("Hibernating...")
            : const Text("Hibernate All Apps"),
        icon: _isHibernating
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white))
            : const Icon(Icons.power_settings_new_rounded),
        backgroundColor: _isHibernating ? Colors.grey : Colors.blue,
      ),
    );
  }
}
