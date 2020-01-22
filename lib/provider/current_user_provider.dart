import 'package:flutter/cupertino.dart';
import 'package:pothole/helpers/firebase_auth.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/models/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUserProvider with ChangeNotifier{
  Profile _profile;

  Profile get profile{
    return _profile;
  }

  Future<void> getCurrentUser() async {
    try {
      final cUser = await Auth().getCurrentUser();
      if(cUser == null)
        return;

      final response = await Firestore.instance
          .collection("users")
          .document(cUser.uid)
          .get();

      _profile = Profile(
        id: cUser.uid,
        name: response.data["name"],
        email: cUser.email,
        role: response.data["role"],
      );
      notifyListeners();
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> addComplaint(Complaint complaint) async{
    final data = {
      "authorId": complaint.authorId,
      "image": complaint.image,
      "description": complaint.description,
      "lat": complaint.lat,
      "lan":complaint.lan,
      "time": DateTime.now().toIso8601String(),
      "isAnonymous": complaint.isAnonymous,
      "status": "Pending",
      "progress": 0,
      "approved": false,
      "priority": "Medium"
    };

    try{
      await Firestore.instance.collection("complaints").document().setData(data);
    }on Exception catch(e){
      throw e;
    }
  }
}