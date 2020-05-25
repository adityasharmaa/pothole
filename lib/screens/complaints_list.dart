import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/helpers/messaging.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/provider/complaints_provider.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/widgets/complaint.dart';
import 'package:pothole/widgets/notification_dialog.dart';
import 'package:provider/provider.dart';

enum PopupMenuEntries {
  Reload,
  LogOut,
}

class ComplaintsList extends StatefulWidget {
  static const route = "/complaints_list";

  @override
  _ComplaintsListState createState() => _ComplaintsListState();
}

class _ComplaintsListState extends State<ComplaintsList> {

  static bool _isNotificationShowing = false;
  bool _isLoading = true;

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
    _configureFCM();
    _fetchData();
  }

  void _fetchData(){
    Future.delayed(Duration(milliseconds: 0,), () async{
      await Provider.of<ComplaintsProvider>(context, listen: false).fetchComplaints();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _configureFCM(){
    _firebaseMessaging.configure(
      onBackgroundMessage: Messaging.myBackgroundMessageHandler,
      onMessage: (message) async => onMessage(context, message),
      onLaunch: (message) async => onLaunch(context, message),
      onResume: (message) async => onResume(context, message), // external lib
    );
    final currentUser = Provider.of<CurrentUserProvider>(context,listen: false).profile;
    _firebaseMessaging.subscribeToTopic(currentUser.id);
    if(currentUser.role == "Civil Agency")
      _firebaseMessaging.subscribeToTopic("civil_agency");
  }

  Widget _complaintsList(List<Complaint> complaints) {
    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (_, index) => ComplaintWidget(complaints[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaints = Provider.of<ComplaintsProvider>(context,listen: true);
    final user = Provider.of<CurrentUserProvider>(context, listen: false).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
        actions: <Widget>[
          Center(
            child: Text(user.role),
          ),
          PopupMenuButton<PopupMenuEntries>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
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
                 complaints.fetchComplaints();

              } else {
                await _firebaseMessaging.unsubscribeFromTopic("civil_agency");
                await _firebaseMessaging.unsubscribeFromTopic(Provider.of<CurrentUserProvider>(context,listen: false).profile.id);
                await Auth().signOut();
                Navigator.of(context).pushReplacementNamed(AuthScreen.route);
              }
            },
          ),
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),)
          : _complaintsList(complaints.complaints),
    );
  }
}
