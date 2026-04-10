import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> init() async {
    FirebaseMessaging.instance.requestPermission(provisional: true);

    final token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("New Token: $newToken");
    });
  }
}
