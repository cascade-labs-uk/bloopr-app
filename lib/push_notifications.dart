import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:blooprtest/backend.dart';
import 'dart:io' show Platform;

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  BaseBackend backend = new Backend();

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission firs t.
      if(Platform.isIOS) {
        _firebaseMessaging.requestNotificationPermissions(
            IosNotificationSettings()
        );
      } else {
        _firebaseMessaging.requestNotificationPermissions();
      }
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      backend.updateUserToken(token);

      _initialized = true;
    }
  }


}