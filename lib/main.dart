import 'package:flutter/material.dart';
import 'package:pothole/provider/camera_provider.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/provider/googlemap_provider.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/screens/detailpage.dart';
import 'package:pothole/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'screens/citizen/screen_selector.dart';
import 'widgets/custom_camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: CameraProvider(),
        ),
        ChangeNotifierProvider.value(
          value: CurrentUserProvider(),
        ),
        ChangeNotifierProvider.value(
          value: GoogleMapProvider(),
        )
      ],
      child:  MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.yellow,
      ),
      //home: SplashScreen(),
      home: DetailPage(),
      routes: {
        ScreenSelector.route: (_) => ScreenSelector(),
        AuthScreen.route: (_) => AuthScreen(),
        TakePictureScreen.route:(_)=>TakePictureScreen(),
        
      },
    ),
    );
    
   
  }
}
