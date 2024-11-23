import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notfications/main.dart';
import 'package:firebase_push_notfications/utils/routes/route_name.dart';

//handle background message must be a top-level function
Future<void> handleBackgroundMessage(RemoteMessage message) async{
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handleMessage(RemoteMessage? message) async{
    if(message == null) return;

    await navigatorKey.currentState?.pushNamed(
      RouteName.notificationScreen,
      arguments: message,
    );
  }

  Future<void> initNotification() async {
    try{
      await _firebaseMessaging.setAutoInitEnabled(false);
      await _firebaseMessaging.requestPermission();
      String? FCMToken = await _firebaseMessaging.getToken();
      print("Token: ${FCMToken}");
      initPushNotification();
    }
    catch(e){
      log("Error: $e");
    }
  }

  Future<void> initPushNotification() async{
    //essential for IOS foreground notification
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      sound: true,
      badge: true,
      alert: true,
    );

    //when app is open from terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    //when app is open from background state via notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    //TODO: learn what does this do?
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}