import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionRequestBottomSheet extends StatefulWidget {
  const NotificationPermissionRequestBottomSheet({super.key});

  @override
  State<NotificationPermissionRequestBottomSheet> createState() =>
      _NotificationPermissionRequestBottomSheetState();
}

class _NotificationPermissionRequestBottomSheetState
    extends State<NotificationPermissionRequestBottomSheet> {
  Future<PermissionStatus?> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      return status;
    } else if (status.isDenied) {
      PermissionStatus newStatus = await Permission.notification.request();
      if (newStatus.isGranted) {
        return newStatus;
      } else if (newStatus.isPermanentlyDenied) {
        return newStatus;
      } else {
        return PermissionStatus
            .permanentlyDenied; // just to prevent some edge cases
      }
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied
      return status;
    }

    return status;
  }

  void _showOpenSettingsDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Theme.of(context).cardColor,
          content: Text(
            'It looks like you have turned off notifications permission. Please enable them in: Settings > Apps > Dashboard > Permissions > Notifications > Allow',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(
                                  color: Theme.of(context).dividerColor)))),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: Text('Open Settings',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      )),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Enable Push Notifications",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Allow push notifications permission to enhance cab sharing and lost & found features, plus get timely timetable reminders, event alerts, and more.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(color: Colors.blue)))),
                  onPressed: () async {
                    PermissionStatus? res =
                        await requestNotificationPermission();
                    Navigator.pop(context);
                    if (res != null) {
                      if (res.isPermanentlyDenied) {
                        _showOpenSettingsDialog(context);
                      }
                    }
                  },
                  child: const Text(
                    "Allow Notifications",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
