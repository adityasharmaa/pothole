import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapProvider with ChangeNotifier {
  Position _position;

  Position get currentPosition {
    return _position;
  }

  void changePosition(Position currentValue){
    _position=currentValue;
    notifyListeners();
  }
}
