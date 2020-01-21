import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/screens/screen_selector.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _logoAnimation;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _logoAnimation = Tween<double>(begin: 70, end: 120).animate(CurvedAnimation(
      curve: Interval(0.0, 1, curve: Curves.easeInOut),
      parent: _animationController,
    ));

    _logoAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });
    _animationController.forward();
    _initTimer();
  }

  void _initTimer(){
    _timer = Timer(Duration(seconds: 4), () async{
      final user = await Auth().getCurrentUser();
      if(user != null)
        Navigator.of(context).pushReplacementNamed(ScreenSelector.route);
      else
        Navigator.of(context).pushReplacementNamed(AuthScreen.route);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          Center(
            child: SizedBox(
              width: _width,
              height: _height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: _height * 0.2),
                      child: AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Container(
                            height: _logoAnimation.value,
                            width: _logoAnimation.value,
                            child:
                                Image.asset("assets/images/logo.png"),
                          );
                        },
                      ),
                    ),
                    Opacity(
                      opacity: _animationController == null ||
                              _animationController.value != 1
                          ? 0.0
                          : 1.0,
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Potholes Complaint Portal",
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
