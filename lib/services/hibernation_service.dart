import 'package:accessibility_service/accessibility_service.dart';

class HibernationService extends AccessibilityService {
  @override
  void onAccessibilityEvent(AccessibilityEvent event) {
    // Logic to force stop apps will go here in the next step
    print('Received event: ${event.packageName}');
  }

  @override
  void onInterrupt() {
    // Handle interruptions
  }

  @override
  void onServiceConnected() {
    print('Accessibility Service Connected!');
  }
}
