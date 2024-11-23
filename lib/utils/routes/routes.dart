import 'package:firebase_push_notfications/pages/notification_scren.dart';
import 'package:firebase_push_notfications/utils/routes/route_name.dart';
import 'package:flutter/material.dart';

import '../../pages/home_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case RouteName.homeScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const HomeScreen());

      case RouteName.notificationScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const NotificationScreen());

      //add page routes here

      default:
        return MaterialPageRoute(builder: (context){
          return const Scaffold(
            body: Center(
              child: Text("No route defined"),
            ),
          );
        });
    }
  }
}