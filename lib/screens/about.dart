import 'package:flutter/material.dart';
import 'package:pothole/provider/current_user_provider.dart';
import 'package:provider/provider.dart';

class About extends StatelessWidget {
  static const String about =
      "This application is used to report pothole problems nearby you. If you've seen a pothole on the roads or want to tell the authority about the repairmen of roads in your locality you can report it here by capturing the snap using your Android as well as IOS mobile and by providing your basic details. Once you registered a complaint PWD Department will take appropriate action and will notify you once they’ve fixed the problem.\nAlso, you can view the previous complaints and the work progress of these complaints.";
  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<CurrentUserProvider>(context, listen: false);
    return FutureBuilder(
        future: _provider.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Text(
                      "Welcome ${_provider.profile.name},",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "(${_provider.profile.email})",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "About",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      about,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Image.asset("assets/images/pothole.png"),
                    ),
                  ],
                ),
              ),
            );
          } else
            return Center(child: CircularProgressIndicator());
        });
  }
}
