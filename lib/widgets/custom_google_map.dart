import 'dart:async';
import 'package:pothole/provider/googlemap_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CustomGoogleMap extends StatefulWidget {
  @override
  _CustomGoogleMapState createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  Position _currentPosition;
  final Set<Marker> _markers = {};
  bool _hasLoaded=true;
  Completer<GoogleMapController> mapController = Completer();

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _getCurrentLocation(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // google map initializer

    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width,
      child:_hasLoaded?Center(child: CircularProgressIndicator()):Padding(
        padding: EdgeInsets.all(1.0),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GoogleMap(
              zoomGesturesEnabled: true,
              markers: _markers,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _markers.elementAt(0).position,
                zoom: 17,
              ),
              gestureRecognizers: Set()
                ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                ..add(
                  Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer()),
                )
                ..add(
                  Factory<HorizontalDragGestureRecognizer>(
                      () => HorizontalDragGestureRecognizer()),
                )
                ..add(
                  Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                ),
            ),
            ),
            Positioned(
              top: 0,
              right: 2,
              child: IconButton(
                icon: Icon(Icons.refresh,size: 35,),
                onPressed: ()=>_getCurrentLocation(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation(BuildContext context) {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position newPosition) {
      setState(() {
        _currentPosition = newPosition;
        Provider.of<GoogleMapProvider>(context,listen: false).changePosition(newPosition);
        _markers.add(Marker(
          markerId: MarkerId("1"),
          position: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          // infoWindow: InfoWindow(
          // )
        ));
      });
      _hasLoaded=false;
    }).catchError((e) {
      print(e);
    });
  }
}
