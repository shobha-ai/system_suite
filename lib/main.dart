import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

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
  List<AppInfo>? _installedApps;

  @override
  void initState() {
    super.initState();
    // Get the list of apps when the screen loads
    InstalledApps.getInstalledApps(true, true).then((apps) {
      setState(() {
        _installedApps = apps;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Installed Applications"),
      ),
      body: _installedApps == null
          // Show a loading circle while the apps are being scanned
          ? const Center(child: CircularProgressIndicator())
          // Once loaded, show the list of apps
          : ListView.builder(
              itemCount: _installedApps!.length,
              itemBuilder: (context, index) {
                AppInfo app = _installedApps![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    // Show the app's icon
                    child: Image.memory(app.icon!),
                  ),
                  // Show the app's name
                  title: Text(app.name ?? "Unknown App"),
                  // Show the app's package name
                  subtitle: Text(app.packageName ?? "Unknown Package"),
                );
              },
            ),
    );
  }
}
