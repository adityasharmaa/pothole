import 'package:flutter/cupertino.dart';

class Profile{
  final String id, name, role, email, image;
  Profile({
    @required this.id,
    @required this.name,
    @required this.role,
    @required this.email,
    this.image,
  });
}