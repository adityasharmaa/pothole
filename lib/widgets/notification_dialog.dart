import 'package:flutter/material.dart';
import 'package:pothole/provider/complaints_provider.dart';
import 'package:pothole/provider/my_complaints_provider.dart';
import 'package:pothole/screens/complaint_detail_page.dart';
import 'package:provider/provider.dart';

class NotificationDialog extends StatelessWidget {
  final Map<String, dynamic> message;
  NotificationDialog(this.message);

  void _gotoDetailPage(String complainId, BuildContext context) {
    final complaints =
        Provider.of<MyComplaintsProvider>(context, listen: false).complaints;
    int index = complaints.indexWhere((complaint) {
      return complaint.id == complainId;
    });
    Navigator.of(context)
        .pushNamed(DetailPage.route, arguments: complaints[index]);
  }

  void _reloadComplaintsList(BuildContext context) {
    Provider.of<ComplaintsProvider>(context, listen: false).fetchComplaints();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
          height: _height * 0.4,
          width: _width * 0.8,
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: _width * 0.8,
                    height: _height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                          message["data"]["image"],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Text(
                      message["notification"]["title"],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 5,
                    ),
                    child: Text(message["notification"]["body"]),
                  ),
                ],
              ),
              Positioned(
                right: 20,
                top: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: Icon(
                      message["data"]["complaint_id"] != null
                          ? Icons.arrow_forward_ios
                          : Icons.replay,
                      color: Colors.white,
                    ),
                    onPressed: () => message["data"]["complaint_id"] != null
                        ? _gotoDetailPage(
                            message["data"]["complaint_id"],
                            context,
                          )
                        : _reloadComplaintsList(context),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
