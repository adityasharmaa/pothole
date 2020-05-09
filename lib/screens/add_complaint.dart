import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pothole/helpers/messaging.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
/*import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as file;*/

class AddComplaint extends StatefulWidget {
  @override
  _AddComplaintState createState() => _AddComplaintState();
}

class _AddComplaintState extends State<AddComplaint> {
  File _pickedImage;
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  bool _isAnonymous = false;
  bool _isPictureValid = false;
  var objectsDetected = [];

  Future<void> getImageInfo(File pickedImage) async {
    objectsDetected = [];
    const String _url = "https://keraspothhole.herokuapp.com/predict";
    final mimeTypeData =
        lookupMimeType(pickedImage.path, headerBytes: [0xFF, 0xD8]).split('/');
    // Intilize the multipart request
    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(_url));
    final file = await http.MultipartFile.fromPath(
      'image', pickedImage.path,
      //contentType: MediaType(mimeTypeData[0], mimeTypeData[1])
    );
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData["success"] == false) {
        return null;
      }
      objectsDetected = responseData["data"];
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getImage(bool useCamera) async {
    final pickedImage = await ImagePicker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedImage == null) return;

    setState(() {
      _pickedImage = pickedImage;
      _isLoading = true;
    });

    // final FirebaseVisionImage visionImage =
    //     FirebaseVisionImage.fromFile(pickedImage);
    // final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    // final List<ImageLabel> labels = await labeler.processImage(visionImage);
    // print("***************************");
    // for(var label in labels){
    // print(label.text);

    // }

    await getImageInfo(_pickedImage);
    for (String item in objectsDetected) {
      print(item);
    }

    setState(() {
      _isLoading = false;
    });

    if ((objectsDetected.contains("asphalt") &&
                objectsDetected.contains("cracks") &&
                objectsDetected.contains("pothole") ||
            objectsDetected.contains("pothole") &&
                objectsDetected.contains("asphalt") ||
            objectsDetected.contains("asphalt") &&
                objectsDetected.contains("cracks") ||
            objectsDetected.contains("cracks") ||
            objectsDetected.contains("pothole") &&
                objectsDetected.contains("cracks")) ||
        objectsDetected.contains("pothole")) {
      if (!objectsDetected.contains("wall") &&
          !objectsDetected.contains("tree")) {
        _isPictureValid = true;
      } else {
        _isPictureValid = false;
        _showErrorDialog(
            "This image does not contain pothole. Please click another image.");
      }
    } else {
      _isPictureValid = false;
      _showErrorDialog(
          "This image does not contain pothole. Please click another image.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Icon(
          Icons.error,
          color: Colors.red,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _fileName(String path) {
    return path.substring(path.lastIndexOf("/") + 1, path.lastIndexOf("."));
  }

  Future<String> _uploadImage() async {
    try {
      final fileName = DateTime.now().toIso8601String();

      StorageTaskSnapshot storageTaskSnapshot;

      storageTaskSnapshot = await FirebaseStorage.instance
          .ref()
          .child("complaints_images")
          .child(fileName)
          .putFile(_pickedImage)
          .onComplete;

      if (storageTaskSnapshot.error == null) {
        final downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        return downloadUrl;
      } else
        _showSnackbar('This file is not an image');
    } catch (e) {
      _showSnackbar(e.toString());
    }
    return "";
  }

  void _showSnackbar(String message) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _fileComplaint() async {
    //final _mapProvider = Provider.of<GoogleMapProvider>(context, listen: false);
    if (_pickedImage == null) {
      _showSnackbar("Please click an image");
      return;
    } else if (!_isPictureValid) {
      _showSnackbar("Invalid picture");
      return;
    } else if (_descriptionController.text.isEmpty) {
      _showSnackbar("Please describe the problem");
      return;
    } else if (_locationController.text.isEmpty) {
      _showSnackbar("Enter location");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var imageUrl = await _uploadImage();
      if (imageUrl.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _showSnackbar("Unable to file complaint.");
        return;
      }

      final currentUser =
          Provider.of<CurrentUserProvider>(context, listen: false);

      final newComplaint = Complaint(
        authorId: currentUser.profile.id,
        description: _descriptionController.text,
        image: imageUrl,
        time: DateTime.now().toIso8601String(),
        isAnonymous: _isAnonymous,
        lat:
            "77.2381475", //TODO _mapProvider.currentPosition.latitude.toString(),
        lan:
            "28.5171999", //TODO mapProvider.currentPosition.longitude.toString(),
        location: _locationController.text,
      );

      await currentUser.addComplaint(newComplaint);

      _showSnackbar("Complaint filed.");

      Messaging.sendNotification(
        topic: "civil_agency",
        title:
            "${newComplaint.location} (${DateFormat.yMMMd().format(DateTime.parse(newComplaint.time))})",
        body: "A new complaint has been filed in your area.",
        image: newComplaint.image,
      );

      setState(() {
        _pickedImage = null;
        _descriptionController.clear();
      });
    } catch (e) {
      _showSnackbar(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _imageButton(String text, IconData icon, bool useCamera) {
    final height = MediaQuery.of(context).size.height;
    return Expanded(
      child: GestureDetector(
        onTap: () => _getImage(useCamera),
        child: Container(
          height: height * 0.05,
          constraints: BoxConstraints(minHeight:32),
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white),
                ),
                Icon(
                  icon,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    return AbsorbPointer(
      absorbing: _isLoading,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: _height * 0.22,
                    width: _width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: _pickedImage == null
                        ? Center(
                            child: Text(
                              "No picture clicked",
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          )
                        : Image.file(_pickedImage),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      _imageButton("Click picture ", Icons.camera_alt, true),
                      SizedBox(width: 5),
                      _imageButton("Open gallery ", Icons.collections, false),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: _height * 0.1,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Describe your problem here"),
                      controller: _descriptionController,
                    ),
                  ),
                  Container(
                    height: _height * 0.1,
                    child: TextField(
                      decoration: InputDecoration(hintText: "Location"),
                      controller: _locationController,
                    ),
                  ),
                  //TODO CustomGoogleMap(),
                  Container(
                    height: _height * 0.4,
                    width: _width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/Delhi_Google_Maps.jpg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Text("Map"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Complain Anonymously?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value;
                          });
                        },
                      ),
                    ],
                  ),
                  InkWell(
                    child: Container(
                      height: _height * 0.05,
                      width: _width,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          "Submit",
                          style: Theme.of(context)
                              .textTheme
                              .subhead
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    onTap: _fileComplaint,
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
            ],
          ),
        ),
      ),
    );
  }
}
