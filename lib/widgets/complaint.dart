import 'package:flutter/material.dart';
import 'package:pothole/models/complaint.dart';
import 'package:intl/intl.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ComplaintWidget extends StatelessWidget {
  final Complaint _complaint;
  ComplaintWidget(this._complaint);
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.shortestSide;
    final _height = MediaQuery.of(context).size.longestSide;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: _height * 0.12,
        width: _width,
        child: Row(
          children: <Widget>[
            Container(
              height: _height * 0.12,
              width: _width * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
                image: DecorationImage(
                  image: NetworkImage(_complaint.image,),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: _width * 0.6,
              padding: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${_complaint.location} (${DateFormat.yMMMd().format(DateTime.parse(_complaint.time))})",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _complaint.description.length < 100
                        ? _complaint.description
                        : (_complaint.description.substring(0, 100) + "..."),
                  ),
                ],
              ),
            ),
            CircularPercentIndicator(
              radius: _width * 0.15,
              lineWidth: 5,
              percent: _complaint.progress.toDouble() / 100.0,
              center: Text("${_complaint.progress}%", style: TextStyle(fontWeight: FontWeight.bold),),
              progressColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
