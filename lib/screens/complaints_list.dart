import 'package:flutter/material.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/provider/complaints_provider.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/screens/auth_screen.dart';
import 'package:pothole/widgets/complaint.dart';
import 'package:provider/provider.dart';

enum PopupMenuEntries {
  Reload,
  LogOut,
}

class ComplaintsList extends StatelessWidget {
  static const route = "/complaints_list";

  Widget _complaintsList(List<Complaint> complaints) {
    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (_, index) => ComplaintWidget(complaints[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaints = Provider.of<ComplaintsProvider>(context);
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
                await Auth().signOut();
                Navigator.of(context).pushReplacementNamed(AuthScreen.route);
              }
            },
          ),
        ],
      ),
      body: complaints.complaints.isEmpty
          ? FutureBuilder(
              future: complaints.fetchComplaints(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                if (snapshot.error != null)
                  return Center(
                    child: Text("Error fetching data!"),
                  );
                return _complaintsList(complaints.complaints);
              },
            )
          : _complaintsList(complaints.complaints),
    );
  }
}
