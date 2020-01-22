import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint{
  final String id, authorId, image, description, location, time, status,lat,lan,priority;
  final bool isAnonymous,approved;
  final int progress;

  Complaint({
    this.id,
    @required this.authorId,
    @required this.image,
    @required this.description,
    @required this.time,
    @required this.isAnonymous,
    this.status,
    this.priority,
    this.approved,
    @required this.lat,
    @required this.lan,
    @required this.location,
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
      lat: snapshot.data["lat"],
      lan: snapshot.data["lan"],
      approved: snapshot.data["approved"],
      priority: snapshot.data["priority"],
    );
  }
}