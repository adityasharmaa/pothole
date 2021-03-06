import 'dart:async';

import 'package:intl/intl.dart';
import 'package:pothole/helpers/http_exception.dart';
import 'package:pothole/helpers/messaging.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/provider/complaints_provider.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/widgets/customtext_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

enum UserType {
  C,
  E,
  A,
}

class DetailPage extends StatefulWidget {
  static const route = "/detail_page";
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _changedStatus;
  String _priority;
  Complaint _complaint;
  bool _edited = false;
  bool _approved;
  UserType _userType;
  int progress;
  bool _isLoading = false;

  final _progressController = TextEditingController();

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      _initialize();
    });
  }

  Completer<GoogleMapController> mapController = Completer();

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  void addMarker() {
    _markers.add(Marker(
      markerId: MarkerId("1"),
      position:
          LatLng(double.parse(_complaint.lat), double.parse(_complaint.lan)),
      // infoWindow: InfoWindow(
      // )
    ));
  }

  void _initialize() {
    setState(() {
      _complaint = ModalRoute.of(context).settings.arguments;
      _approved = _complaint.approved;
      _changedStatus = _complaint.status;
      _priority = _complaint.priority;
      _progressController.value =
          TextEditingValue(text: "${_complaint.progress}");
      _userType = Provider.of<CurrentUserProvider>(context, listen: false)
                  .profile
                  .role ==
              "Civil Agency"
          ? UserType.A
          : Provider.of<CurrentUserProvider>(context, listen: false)
                      .profile
                      .role ==
                  "Citizen"
              ? UserType.C
              : UserType.E;
    });
    addMarker();
  }

  void _updateComplaint() async {
    Map<String, dynamic> data;
    if (_edited) {
      if (_userType == UserType.A)
        data = {
          "status": _changedStatus,
          "progress": int.parse(_progressController.text),
        };
      else
        data = {
          "approved": _approved,
          "priority": _priority,
        };

      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<ComplaintsProvider>(context, listen: false)
            .updateComplaint(_complaint.id, data);
        if (_userType == UserType.A)
          Messaging.sendNotification(
            topic: _complaint.authorId,
            title: "${_complaint.location} (${DateFormat.yMMMd().format(DateTime.parse(_complaint.time))})",
            body: "Your complaint status/progress was updated.",
            image: _complaint.image,
            complaintId: _complaint.id,
          );
      } on HttpException catch (e) {
        _showSnackBar(e.toString());
      } catch (e) {}

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint"),
        actions: <Widget>[
          if (_userType != UserType.C)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateComplaint,
            ),
        ],
      ),
      body: _complaint == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: _height * 0.35,
                        width: _width,
                        child: PageView.builder(
                          itemBuilder: (context, index) {
                            return Image.network(
                              _complaint.image,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: CustomTextView(
                          text: _complaint.description,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Location",
                                style: Theme.of(context).textTheme.subhead),
                            InkWell(
                              onTap: () => openMap(double.parse(_complaint.lat),
                                  double.parse(_complaint.lan)),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "${_complaint.location} ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Status",
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            _userType == UserType.A
                                ? _statusDown()
                                : Text(
                                    _complaint.status,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Progress",
                                style: Theme.of(context).textTheme.subhead),
                            _userType == UserType.C || _userType == UserType.E
                                ? CircularPercentIndicator(
                                    radius: _width * 0.15,
                                    lineWidth: 5,
                                    percent:
                                        _complaint.progress.toDouble() / 100.0,
                                    center: Text(
                                      "${_complaint.progress}%",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    progressColor: Colors.green,
                                  )
                                : SizedBox(
                                    width: _width * 0.20,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Progress",
                                      ),
                                      controller: _progressController,
                                      onChanged: (_) => _edited = true,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (_userType == UserType.E)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Priority",
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              _priorityDown(),
                            ],
                          ),
                        ),
                      if (_userType == UserType.E && _complaint.progress == 100)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Approve",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: _approved,
                                onChanged: (value) {
                                  _edited = true;
                                  setState(() {
                                    _approved = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/images/Delhi_Google_Maps.jpg",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Center(
                            child: Text("Map"),
                          ),
                          /*GoogleMap(
                            zoomGesturesEnabled: true,
                            markers: _markers,
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _markers.elementAt(0).position,
                              zoom: 10,
                            ),
                            gestureRecognizers: Set()
                              ..add(Factory<PanGestureRecognizer>(
                                  () => PanGestureRecognizer()))
                              ..add(
                                Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer()),
                              )
                              ..add(
                                Factory<HorizontalDragGestureRecognizer>(
                                    () => HorizontalDragGestureRecognizer()),
                              )
                              ..add(
                                Factory<ScaleGestureRecognizer>(
                                    () => ScaleGestureRecognizer()),
                              ),
                          ),*/
                        ),
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: _isLoading
                        ? Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                            color: Colors.white.withOpacity(0.8),
                          )
                        : Container(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  DropdownButton _statusDown() => DropdownButton<String>(
        hint: Text("Status"),
        icon: Icon(Icons.arrow_drop_down),
        items: ["Pending", "Initiated", "In progress", "Halfway", "Completed"]
            .map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          _edited = true;
          setState(() {
            _changedStatus = value;
          });
        },
        value: _changedStatus,
      );

  DropdownButton _priorityDown() => DropdownButton<String>(
        hint: Text("Priority"),
        icon: Icon(Icons.arrow_drop_down),
        items: ["Low", "Medium", "High"].map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          _edited = true;
          setState(() {
            _priority = value;
          });
        },
        value: _priority,
      );
}
