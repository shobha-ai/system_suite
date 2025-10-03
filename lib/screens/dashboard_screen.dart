import 'package:accessibility_service/accessibility_service.dart';
import 'package:flutter/material.dart';
import 'package:system_suite/screens/app_manager_screen.dart';
import 'package:system_suite/widgets/dashboard_card.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openStorageSettings() async {
    // ... (this function is the same)
  }

  // --- NEW FUNCTION FOR THE HIBERNATOR ---
  void _handleHibernatorTap(BuildContext context) async {
    bool isServiceEnabled = await AccessibilityService.isAccessibilityPermissionEnabled();

    if (!isServiceEnabled) {
      // If not enabled, show a dialog and take the user to settings
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
              "To hibernate apps, you must enable the Accessibility Service for System Suite. This allows the app to perform the 'Force Stop' action automatically."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Go to Settings"),
              onPressed: () {
                Navigator.of(context).pop();
                AccessibilityService.requestAccessibilityPermission();
              },
            ),
          ],
        ),
      );
    } else {
      // If already enabled, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hibernation service is active!")),
      );
      // In the next step, this will trigger the actual hibernation
    }
  }

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
            icon: Icons.speed_rounded,
            title: "Process Hibernator",
            subtitle: "Stop background apps to free RAM",
            onTap: () => _handleHibernatorTap(context), // Updated onTap
          ),
          // ... (the other cards are the same)
        ],
      ),
    );
  }
}
