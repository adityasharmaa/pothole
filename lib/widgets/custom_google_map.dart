import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap {
  static  Container myGoogleMapItems(String title, double h, double w) {
    // google map initializer
    final Set<Marker> _markers = {};
    Completer<GoogleMapController> mapController = Completer();
    _markers.add(Marker(
          markerId: MarkerId("1"),
          position: LatLng(
              40.07,
              45.08,),
          // infoWindow: InfoWindow(
          // )
          ));

   

    void _onMapCreated(GoogleMapController controller) {
      mapController.complete(controller);
    }

    return Container(
      height: h,
      width: w,
      child: Padding(
        padding: EdgeInsets.all(1.0),
        child: GoogleMap(
          zoomGesturesEnabled: true,
          markers: _markers,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _markers.elementAt(0).position,
            zoom: 4.0,
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
    );}
}