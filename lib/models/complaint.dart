import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint{
  final String id, authorId, image, description, location, time, status;
  final bool isAnonymous;
  final int progress;

  Complaint({
    this.id,
    @required this.authorId,
    @required this.image,
    @required this.description,
    @required this.location,
    @required this.time,
    @required this.isAnonymous,
    this.status,
    this.progress,
  });

  factory Complaint.fromSnapshot(DocumentSnapshot snapshot){
    return Complaint(
      id: snapshot.documentID,
      authorId: snapshot.data["authorId"],
      description: snapshot.data["description"],
      image: snapshot.data["image"],
      isAnonymous: snapshot.data["isAnonymous"],
      location: snapshot.data["location"],
      time: snapshot.data["time"],
      status: snapshot.data["status"],
      progress: snapshot.data["progress"],
    );
  }
}