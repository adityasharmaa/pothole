import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

enum ProgressThickness {
  Thin,
  Moderate,
  Thick,
}

class Progress extends StatefulWidget {
  final double width;
  final StorageTaskSnapshot storageTaskSnapshot;
  Progress({@required this.width,@required this.storageTaskSnapshot});
  @override
  _ProgressState createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  Timer _timer;
  @override
  void initState() {
    super.initState();
    _setListener();
  }

  void _setListener() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final double widthCompleted = widget.storageTaskSnapshot == null
        ? 0
        : widget.storageTaskSnapshot.bytesTransferred *
            widget.width /
            widget.storageTaskSnapshot.totalByteCount;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: widget.width,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Center(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: widthCompleted,
                child: Divider(
                  thickness: 5,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              SizedBox(
                width: widget.width - widthCompleted,
                child: Divider(
                  thickness: 5,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
