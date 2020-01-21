import 'package:flutter/material.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/provider/my_complaints_provider.dart';
import 'package:pothole/screens/about.dart';
import 'package:pothole/screens/add_complaint.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/screens/my_complaints.dart';
import 'add_complaint.dart';
import 'package:provider/provider.dart';

enum PopupMenuEntries {
  Reload,
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _bottomSelectedIndex);
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
              } else {
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
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 100),
                curve: Curves.decelerate);
          });
        },
      ),
    );
  }
}
