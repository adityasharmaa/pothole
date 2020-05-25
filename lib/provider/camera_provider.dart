import 'dart:io';

import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier{
  List<FileSystemEntity> _images = [];
  int _count=0;

  List<FileSystemEntity> get images {
    return [..._images];
  }

  int get count{
    return _count;
  }

  void addCount(int count){
    _count+=1;
    notifyListeners();
  }

  void replaceSingleItem(int position,FileSystemEntity path){
    _images.insert(position, path);
    _images.removeAt(position+1);
    //check runtimeType
    notifyListeners();
  }

  void addallItem(List<FileSystemEntity> images){
    _images=images;
    notifyListeners();
  }

  void removeSingleItem(int position){
    _images.removeAt(position);
    notifyListeners();
  }
  
}