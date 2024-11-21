import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async{
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.setAutoInitEnabled(false);
    await _firebaseMessaging.requestPermission();
    String? FCMToken = await _firebaseMessaging.getToken();
    print("Token: ${FCMToken}");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}