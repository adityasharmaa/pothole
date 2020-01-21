import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole/provider/camera_provider.dart';
import 'package:pothole/widgets/custompageview.dart';
import 'package:provider/provider.dart';


class TakePictureScreen extends StatefulWidget {
  static const route = '/cameraScreen';
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras;
  int selectedCameraIdx;
  bool _isMultipleMode = false;
  String imagePath;
  var _cameraProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    availableCameras().then((_availableCamera) {
      final firstCamera = _availableCamera[0];
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    _cameraProvider =Provider.of<CameraProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Take pictures'),
        
      ),
      body: _isLoading
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return Stack(children: <Widget>[
                    Positioned.fill(child: CameraPreview(_controller)),
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ]);
                } else
                  return Container();
              })
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(child: CameraPreview(_controller)),
                      Positioned(
                        left: _width * 0.25,
                        right: _width * 0.2,
                        bottom: 20,
                        child: Center(
                          child: Row(
                            children: <Widget>[
                              _cameraProvider.count == 0
                                  ? Container(
                                      height: 45,
                                      width: 45,
                                    )
                                  : GestureDetector(
                                      onTap: _isLoading
                                          ? () {}
                                          : () => _showImages(context),
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.orangeAccent),
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: _imageContainer(),
                                          ),
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                width: 35,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    shape: BoxShape.circle),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt,
                                  ),
                                  iconSize: 35,
                                  onPressed: _isLoading
                                      ? () {}
                                      : () async {
                                          if (_cameraProvider.count == 0) {
                                            final Directory extDir =
                                                await getApplicationDocumentsDirectory();
                                            extDir.deleteSync(recursive: true);
                                          }

                                          _cameraProvider.addCount(
                                              _cameraProvider.count + 1);
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          try {
                                            await _captureImage();
                                            _workMulitimode(context);
                                          } catch (e) {
                                            print(e);
                                          }
                                        },
                                ),
                              ),
                              SizedBox(
                                width: 28,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.collections,
                                  color: _isMultipleMode
                                      ? Colors.orangeAccent
                                      : Colors.white,
                                ),
                                iconSize: 35,
                                onPressed: () {
                                  setState(() {
                                    _isMultipleMode = !_isMultipleMode;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }

  
  ImageProvider _imageContainer() {
    if (imagePath == null) {
      if (_cameraProvider.images.length > 0 && _cameraProvider.count > 0) {
        return FileImage(
            File(_cameraProvider.images[_cameraProvider.images.length-1].path));
      } else
        AssetImage("assets/images/empty.png");
    } else
      return FileImage(File(imagePath));
  }

  Future<void> _captureImage() async {
    await _initializeControllerFuture;
    if (_controller.value.isInitialized) {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/media';
      await Directory(dirPath).create(recursive: true);
      imagePath = '$dirPath/${DateTime.now()}.jpeg';
      await _controller.takePicture(imagePath);

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _workMulitimode(BuildContext context) {
    _isMultipleMode ? setState(() {}) : _showImages(context);
  }

  Future<void> _showImages(BuildContext context) async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    _cameraProvider.addallItem(
        Directory(dirPath).listSync(recursive: true, followLinks: true));
    if (_cameraProvider.images.length > 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return CustomPageView(images: _cameraProvider.images);
          },
        ),
      );
    }
  }
}
