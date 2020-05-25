import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/screens/complaints_list.dart';
import 'package:pothole/screens/screen_selector.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _logoAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _logoAnimation =
        Tween<double>(begin: 100, end: 200).animate(CurvedAnimation(
      curve: Interval(0.0, 1, curve: Curves.easeInOut),
      parent: _animationController,
    ));

    _logoAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });
    _animationController.forward();
    _init();
  }

  

  void _init() async {
    final user = await Auth().getCurrentUser();
    if (user != null) {
      final currentUser =
          Provider.of<CurrentUserProvider>(context, listen: false);
      await currentUser.getCurrentUser();
      if (currentUser.profile.role == "Citizen")
        Navigator.of(context).pushReplacementNamed(ScreenSelector.route);
      else
        Navigator.of(context).pushReplacementNamed(ComplaintsList.route);
    } else
      Navigator.of(context).pushReplacementNamed(AuthScreen.route);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.longestSide;
    final _width = MediaQuery.of(context).size.shortestSide;
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
                            child: Image.asset("assets/images/logo.png"),
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
