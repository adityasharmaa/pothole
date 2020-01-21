import 'package:flutter/material.dart';
import 'package:pothole/provider/cameraprovider.dart';
import 'package:pothole/widgets/custom_camera.dart';
import 'package:pothole/widgets/custom_google_map.dart';
import 'package:provider/provider.dart';

class AddComplaint extends StatefulWidget {
  AddComplaint({Key key}) : super(key: key);

  @override
  _AddComplaintState createState() => _AddComplaintState();
}

class _AddComplaintState extends State<AddComplaint> {
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    final _cameraProvider = Provider.of<CameraProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _cameraProvider.images.length == 0
                ? Container(
                    height: _height * 0.22,
                    width: _width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        "No picture clicked !!!",
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                  )
                : LimitedBox(
                    maxHeight: _height * 0.22,
                    maxWidth: _width,
                    child: Center(
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _cameraProvider.images.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: _height * 0.15,
                            width: _width,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: FileImage(
                                  _cameraProvider.images[index],
                                ),
                              ),
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180,
                            childAspectRatio: 1.8 / 2,
                            mainAxisSpacing: 2),
                      ),
                    )),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, TakePictureScreen.route),
              child: Container(
                  height: _height * 0.06,
                  width: _width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Take a Picture",
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(color: Colors.white)),
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            // Align(alignment: Alignment.centerLeft,child: Text("Description",style: Theme.of(context).textTheme.subhead.copyWith(color:Colors.black),)),
            SizedBox(
              height: 5,
            ),
            Container(
              height: _height * 0.09,
              width: _width,
              // decoration:
              //     BoxDecoration(border: Border.all(color: Colors.black)),
              child: TextField(
                decoration: InputDecoration(hintText: "Describe your problem here"),
                
              ),
            ),
           CustomGoogleMap(),
           
          ],
        ),
      ),
    );
  }
}
