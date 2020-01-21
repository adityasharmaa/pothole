import 'dart:io';

import 'package:flutter/material.dart';

class CustomPageView extends StatefulWidget {
  final List<FileSystemEntity> images;
  const CustomPageView({Key key, this.images}) : super(key: key);
  @override
  _CustomPageViewState createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  List<FileSystemEntity> imageList;
  bool _showDeleteButton=false;
  @override
  void initState() {
    super.initState();
    imageList = widget.images.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body:PageView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.images.length>1?widget.images.length - 1:widget.images.length,
          itemBuilder: (BuildContext context, int index) {
            return Stack(
              children: <Widget>[
                GestureDetector(
                  child: 
                   Container(
                    height: _height,
                    width: _width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: FileImage(
                        File(imageList[index].path),
                      ),
                      fit: BoxFit.cover,
                    )),
                  ),
                  onTap: (){
                      setState(() {
                        _showDeleteButton=!_showDeleteButton;
                      });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom:12.0),
                  child:!_showDeleteButton?Container(): Align(alignment: Alignment.bottomCenter,child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.replay,size: 30,color: Colors.orange,),onPressed: (){},),
                      SizedBox(width: 30),
                      IconButton(icon: Icon(Icons.delete,size: 30,color: Colors.orange,), onPressed: () {},),
                    ],
                  ),),
                )
              ],
            );
          },
        ),
      
    );
  }
}
