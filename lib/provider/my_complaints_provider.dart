import 'package:flutter/foundation.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/models/complaint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyComplaintsProvider with ChangeNotifier {
  List<Complaint> _complaints = [];

  List<Complaint> get complaints {
    return [..._complaints];
  }

  Future<void> fetchComplaints() async {
    try {
      final cUser = await Auth().getCurrentUser();
      if (cUser == null) return;

      final response = await Firestore.instance
          .collection("complaints")
          .where("authorId", isEqualTo: cUser.uid)
          .getDocuments();

      _complaints = response.documents
          .map((snapshot) => Complaint.fromSnapshot(snapshot))
          .toList();

      notifyListeners();
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
