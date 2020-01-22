import 'package:flutter/material.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/provider/complaints_provider.dart';
import 'package:pothole/widgets/complaint.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
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
