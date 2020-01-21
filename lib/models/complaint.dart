import 'package:flutter/foundation.dart';

class Complaint{
  final String id, authorId, image, description, location, time;
  final bool isAnonymous;
  Complaint({
    this.id,
    @required this.authorId,
    @required this.image,
    @required this.description,
    @required this.location,
    @required this.time,
    @required this.isAnonymous,
  });
}