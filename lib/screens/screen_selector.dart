import 'package:flutter/material.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/screens/add_complaint.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'add_complaint.dart';
import 'home.dart';

class ScreenSelector extends StatefulWidget {
  static const route = "/screen_selector";
  @override
  _ScreenSelectorState createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  int _bottomSelectedIndex = 1;
  PageController _pageController;
  List<String> _categoryList = ["Add Complaint", "Home", "My Complaints"];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _bottomSelectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryList[_bottomSelectedIndex]),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: ()async{
              await Auth().signOut();
              Navigator.of(context).pushReplacementNamed(AuthScreen.route);
            },
          )
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
          Home(),
          Home(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomSelectedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text("Add Complaint"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create_new_folder),
            title: Text("My Complaints"),
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
