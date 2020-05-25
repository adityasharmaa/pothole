import 'package:flutter/foundation.dart';
import 'package:pothole/models/complaint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintsProvider with ChangeNotifier{
  List<Complaint> _complaints = [];

  List<Complaint> get complaints{
    return [..._complaints];
  }

  Future<void> fetchComplaints() async{

    try {
      final response = await Firestore.instance
          .collection("complaints")
          .getDocuments();

      _complaints = response.documents.map((snapshot) => Complaint.fromSnapshot(snapshot)).toList();
      notifyListeners();
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> updateComplaint(String id, Map<String,dynamic> data) async{
    try{
      await Firestore.instance.collection("complaints").document(id).updateData(data);
    }catch(e){
      print(e.toString());
      throw e;
    }
  }
}