import 'package:flutter/material.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/helpers/messaging.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/provider/my_complaints_provider.dart';
import 'package:pothole/screens/about.dart';
import 'package:pothole/screens/add_complaint.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/screens/my_complaints.dart';
import 'package:pothole/widgets/notification_dialog.dart';
import 'add_complaint.dart';
import 'package:provider/provider.dart';
import 'about.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum PopupMenuEntries {
  Reload,
  Test,
  LogOut,
}

class ScreenSelector extends StatefulWidget {
  static const route = "/screen_selector";
  @override
  _ScreenSelectorState createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  int _bottomSelectedIndex = 1;
  PageController _pageController;
  List<String> _titleList = ["Add Complaint", "My Complaints", "About"];
  static bool _isNotificationShowing = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static Future<dynamic> onMessage(
      BuildContext context, Map<String, dynamic> message) async {
    if (!_isNotificationShowing) {
      _isNotificationShowing = true;
      showDialog(
        context: context,
        builder: (_) => NotificationDialog(message),
      ).then((_) {
        _isNotificationShowing = false;
      });
    }
  }

  static Future<dynamic> onResume(
      BuildContext context, Map<String, dynamic> message) async {
    print("onResume: $message");
  }

  static Future<dynamic> onLaunch(
      BuildContext context, Map<String, dynamic> message) async {
    print("onLaunch: $message");
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _bottomSelectedIndex);
    _firebaseMessaging.configure(
      onBackgroundMessage: Messaging.myBackgroundMessageHandler,
      onMessage: (message) async => onMessage(context, message),
      onLaunch: (message) async => onLaunch(context, message),
      onResume: (message) async => onResume(context, message), // external lib
    );
    _firebaseMessaging.subscribeToTopic(Provider.of<CurrentUserProvider>(context,listen: false).profile.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleList[_bottomSelectedIndex]),
        actions: <Widget>[
          PopupMenuButton<PopupMenuEntries>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              if (_bottomSelectedIndex == 1)
                PopupMenuItem(
                  child: Text("Reload"),
                  value: PopupMenuEntries.Reload,
                ),
              PopupMenuItem(
                child: Text("Log Out"),
                value: PopupMenuEntries.LogOut,
              ),
            ],
            onSelected: (selectedValue) async {
              if (selectedValue == PopupMenuEntries.Reload) {
                Provider.of<MyComplaintsProvider>(context, listen: false)
                    .fetchComplaints();
              } else if (selectedValue == PopupMenuEntries.LogOut) {
                await _firebaseMessaging.unsubscribeFromTopic(Provider.of<CurrentUserProvider>(context,listen: false).profile.id);
                await Auth().signOut();
                Navigator.of(context).pushReplacementNamed(AuthScreen.route);
              }
            },
          ),
        ],
      ),
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            _bottomSelectedIndex = index;
          });
        },
        controller: _pageController,
        children: <Widget>[
          AddComplaint(),
          MyComplaints(),
          About(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomSelectedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.create_new_folder),
            title: Text(_titleList[0]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text(_titleList[1]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            title: Text(_titleList[2]),
          ),
        ],
        onTap: (index) {
          setState(() {
            _bottomSelectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 100),
              curve: Curves.decelerate,
            );
          });
        },
      ),
    );
  }
}
