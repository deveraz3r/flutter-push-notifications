import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notfications/main.dart';
import 'package:firebase_push_notfications/utils/routes/route_name.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//handle background message must be a top-level function
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  //notification category, also register it in android manifest file, then create notification channel using this config
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high, // Importance level
    playSound: true, // Whether to play a sound
  );

  //create flutter local plugin instance
  final _localNotifications = FlutterLocalNotificationsPlugin();

  //fun to send background/terminated message to notification screen
  Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    await navigatorKey.currentState?.pushNamed(
      RouteName.notificationScreen,
      arguments: message,
    );
  }

  Future<void> initNotification() async {
    try {
      await _firebaseMessaging.requestPermission();
      String? FCMToken = await _firebaseMessaging.getToken();
      print("Token: ${FCMToken}");
      initPushNotification(); //background/terminated state logic
      initLocalNotification(); //foreground state logic
    } catch (e) {
      log("Error: $e");
    }
  }

  Future<void> initLocalNotification() async {
    // const iOS = IOSInitializationSettings(); //deprecated method
    const iOS = DarwinInitializationSettings(); //iOS specific initialization

    //android specific initialization
    const android = AndroidInitializationSettings('@drawable/ic_launcher');

    //combine initialization setting
    const settings = InitializationSettings(
      android: android,
      iOS: iOS,
    );

    //Initialize local notifications with the new callback for notification taps
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        //note: onSelectNotification is deprecated and is replaced by onDidReceiveNotificationResponse
        //this method is triggered when user taps notification while application is in foreground
        if (response.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
          handleMessage(message); //navigates app to notification screen
        }
      },
    );

    //resolve platform specific implementation for android  TODO: why??
    final androidPlatform =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    //create notification channel for android todo: didn't we already register it in manifest?
    await androidPlatform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initPushNotification() async {
    //essential for IOS foreground notification TODO: learn more about this
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
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

    //triggers when ever message arrives and our application is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      //extract notification object from message object
      final RemoteNotification? notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode, //notification id
        notification.title, //notification title
        notification.body, //notification body
        NotificationDetails(
          android: AndroidNotificationDetails(
              _androidChannel.id, //channel id
              _androidChannel.name, //channel name
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher'),
        ),
        //payload only accepts String? so we type cast data of message
        payload: jsonEncode(message.toMap()),
      );
    });
  }
}
