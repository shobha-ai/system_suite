import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppManagerScreen extends StatefulWidget {
  const AppManagerScreen({super.key});
  @override
  State<AppManagerScreen> createState() => _AppManagerScreenState();
}

class _AppManagerScreenState extends State<AppManagerScreen> {
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
        // This is the clean filtering logic that now works
        _displayedApps = _allApps.where((app) => app.isSystemApp == false).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Manager")),
      body: Column(
        children: [
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
          const Divider(height: 1),
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
