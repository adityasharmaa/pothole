import 'package:flutter/material.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/screens/screen_selector.dart';
import 'package:pothole/screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.yellow,
      ),
      home: SplashScreen(),
      routes: {
        ScreenSelector.route: (_) => ScreenSelector(),
        AuthScreen.route: (_) => AuthScreen(),
      },
    );
  }
}
