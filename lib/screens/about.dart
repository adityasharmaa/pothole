import 'package:flutter/material.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:provider/provider.dart';

class About extends StatelessWidget {
  final String about = "This application is used to report pothole problems nearby you. If you've seen a pothole on the roads or want to tell the authority about the repairmen of roads in your locality you can report it here by capturing the snap using your Android as well as IOS mobile and by providing your basic details. Once you registered a complaint PWD Department will take appropriate action and will notify you once they’ve fixed the problem. Also, you can view the previous complaints and the work progress of these complaints.";
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<CurrentUserProvider>(context).profile;
    return Column(
      children: <Widget>[
        Text("Welcome ${_currentUser.name},"),
        Text("(${_currentUser.email})"),
        Text("About"),
        Text(about),
      ],
    );
  }
}