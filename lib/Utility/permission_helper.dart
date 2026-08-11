import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Request camera, gallery (photos + storage) permissions
  static Future<void> requestImagePermissions(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.storage,
      Permission.camera,
    ].request();

    _checkPermanentlyDenied(statuses, context);
  }

  /// Request only location permission
  static Future<void> requestLocationPermission(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
    _checkPermanentlyDenied(statuses, context);
  }

  /// Request only gallery (photos + storage) permission
  static Future<void> requestGalleryPermission(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.storage,
    ].request();

    _checkPermanentlyDenied(statuses, context);
  }

  /// Request all required permissions (useful in splash/init)
  static Future<void> requestAllPermissions(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.photos,
      Permission.storage,
      Permission.camera,
    ].request();

    _checkPermanentlyDenied(statuses, context);
  }

  /// Helper to open settings if any permission is permanently denied
  static void _checkPermanentlyDenied(
      Map<Permission, PermissionStatus> statuses, BuildContext context) async {
    print(statuses.toString());
    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      bool? open = await showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: const Text('Permanently Denied'),
                content:
                    const Text('Please enable permissions in app settings'),
                actions: [
                  CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Ok'))
                ],
              ));
      if (open ?? false) {
        openAppSettings();
      }
    }
  }
}
