import 'package:drone_s500/src/app/views/dashboard_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => DashboardPage());
      case '/addUserSettings':
        return MaterialPageRoute(
            //builder: (_)=> AddProduct()
            );
      case '/fetchUserSettings':
        return MaterialPageRoute(
            //builder: (_)=> UserSetting()
            );
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
