import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_push_notfications/pages/home_screen.dart';
import 'package:firebase_push_notfications/pages/notification_scren.dart';
import 'package:firebase_push_notfications/utils/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'api/firebase_api.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        RouteName.notificationScreen: (context) => const NotificationScreen()
      },
    );
  }
}
