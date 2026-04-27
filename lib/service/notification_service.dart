import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> _requestPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      return true;
    } else {
      print('User declined or has not accepted permission');
      return false;
    }
  }

  Future<String?> getToken() async {
    bool pres = await _requestPermission();
    if (pres) { 
      final token = await firebaseMessaging.getToken();
      
      print("FCM Token: $token");

      return token;
    } else {
      return null;
    }
  }
 
}
