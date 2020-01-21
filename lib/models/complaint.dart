import 'package:flutter/foundation.dart';

class Complaint{
  final String id, authorId, image, description, time,lat,lan;
  final bool isAnonymous;
  final int progress;

  Complaint({
    this.id,
    @required this.authorId,
    @required this.image,
    @required this.description,
    @required this.time,
    @required this.isAnonymous,
    @required this.lat,
    @required this.lan,
    this.progress,
  });
}