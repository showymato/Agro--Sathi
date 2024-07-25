 import 'package:flutter/material.dart';
 import 'src/app/views/intro_page.dart';


void main() => runApp(new MyApp());

bool _allow = false;
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async {
        return Future.value(_allow);
      },
      child: new MaterialApp(title: 'Drone Application', home: new IntroPage()),
    );
  }
}
