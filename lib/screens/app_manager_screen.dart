import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppManagerScreen extends StatefulWidget {
  const AppManagerScreen({super.key});

  @override
  State<AppManagerScreen> createState() => _AppManagerScreenState();
}

class _AppManagerScreenState extends State<AppManagerScreen> {
  List<AppInfo>? _apps;
  bool _showSystemApps = false;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  void _loadApps() {
    setState(() { _apps = null; });
    InstalledApps.getInstalledApps(_showSystemApps, true).then((apps) {
      setState(() {
        apps.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
        _apps = apps;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Manager"),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Show System Apps"),
            value: _showSystemApps,
            onChanged: (bool value) {
              setState(() {
                _showSystemApps = value;
                _loadApps();
              });
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: _apps == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _apps!.length,
                    itemBuilder: (context, index) {
                      AppInfo app = _apps![index];
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
