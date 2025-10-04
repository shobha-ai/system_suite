import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter/material.dart';
import 'package:system_suite/screens/app_manager_screen.dart';
import 'package:system_suite/widgets/dashboard_card.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Suite Dashboard"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          DashboardCard(
            icon: Icons.apps_rounded,
            title: "App Manager",
            subtitle: "Manage installed applications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppManagerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
