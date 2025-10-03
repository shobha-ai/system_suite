import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:url_launcher/url_launcher.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  List<AppInfo> _allApps = [];
  List<AppInfo> _displayedApps = [];
  bool _showSystemApps = false;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  void _loadApps() {
    setState(() { _displayedApps = []; });
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
        _displayedApps = _allApps.where((app) => !app.isSystemApp!).toList();
      }
    });
  }

  void _openStorageSettings() async {
    const url = 'android.settings.INTERNAL_STORAGE_SETTINGS';
    if (await canLaunchUrl(Uri.parse('intent://#Intent;action=$url;end'))) {
      await launchUrl(Uri.parse('intent://#Intent;action=$url;end'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Suite Dashboard"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12.0),
            child: ListTile(
              leading: const Icon(Icons.cleaning_services_rounded, size: 32.0),
              title: const Text("Junk & Cache Cleaner"),
              subtitle: const Text("Open system storage to clear cache"),
              onTap: _openStorageSettings,
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text("Show System Apps"),
            value: _showSystemApps,
            onChanged: (bool value) {
              setState(() {
                _showSystemApps = value;
                _filterApps();
              });
            },
          ),
          Expanded(
            child: _allApps.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _displayedApps.length,
                    itemBuilder: (context, index) {
                      AppInfo app = _displayedApps[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Image.memory(app.icon!),
                        ),
                        title: Text(app.name ?? "Unknown App"),
                        subtitle: Text(app.packageName ?? "Unknown Package"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
