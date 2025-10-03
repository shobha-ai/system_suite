import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Suite',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const AppListScreen(),
    );
  }
}

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
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

  // --- NEW FUNCTION TO OPEN STORAGE SETTINGS ---
  void _openStorageSettings() async {
    const url = 'android.settings.INTERNAL_STORAGE_SETTINGS';
    // We use a Uri to launch the Android Intent
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
          // --- NEW WIDGET FOR THE CACHE CLEANER ---
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

          // --- EXISTING WIDGET FOR THE APP LIST ---
          SwitchListTile(
            title: const Text("Show System Apps"),
            value: _showSystemApps,
            onChanged: (bool value) {
              setState(() { _showSystemApps = value; });
              _loadApps();
            },
          ),
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
