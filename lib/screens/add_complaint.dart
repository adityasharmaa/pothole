import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pothole/models/complaint.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/provider/googlemap_provider.dart';
import 'package:pothole/widgets/custom_google_map.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddComplaint extends StatefulWidget {
  @override
  _AddComplaintState createState() => _AddComplaintState();
}

class _AddComplaintState extends State<AddComplaint> {
  File _pickedImage;
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isAnonymous = false;

  Future<void> _getImage() async {
    final pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _pickedImage = pickedImage;
    });
  }

  Future<String> _uploadImage() async {
    try {
      final fileName =
          Provider.of<CurrentUserProvider>(context, listen: false).profile.id;

      final storageTaskSnapshot = await FirebaseStorage.instance
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
    final _mapProvider=Provider.of<GoogleMapProvider>(context,listen: false);
    if (_pickedImage == null) {
      _showSnackbar("Please click an image");
      return;
    } else if (_descriptionController.text.isEmpty) {
      _showSnackbar("Please describe the problem");
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

      await currentUser.addComplaint(
        Complaint(
          authorId: currentUser.profile.id,
          description: _descriptionController.text,
          image: imageUrl,
          time: DateTime.now().toIso8601String(),
          isAnonymous: _isAnonymous,
          lat: _mapProvider.currentPosition.latitude.toString(),
          lan: _mapProvider.currentPosition.longitude.toString(),
        ),
      );

      _showSnackbar("Complaint filed.");

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
                  GestureDetector(
                    onTap: _getImage,
                    child: Container(
                      height: _height * 0.05,
                      width: _width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Take a Picture ",
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(color: Colors.white),
                            ),
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
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

                  CustomGoogleMap(),

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
