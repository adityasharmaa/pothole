import 'package:flutter/material.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/provider/my_complaints_provider.dart';
import 'package:pothole/widgets/complaint.dart';

import 'package:provider/provider.dart';

class MyComplaints extends StatelessWidget {
  Widget _complaintsList(List<Complaint> complaints) {
    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (_, index) => ComplaintWidget(complaints[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myComplaints = Provider.of<MyComplaintsProvider>(context);
    return myComplaints.complaints.isEmpty
        ? FutureBuilder(
            future: myComplaints.fetchComplaints(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );
              if (snapshot.error != null)
                return Center(
                  child: Text("Error fetching data!"),
                );
              return _complaintsList(myComplaints.complaints);
            },
          )
        : _complaintsList(myComplaints.complaints);
  }
}
