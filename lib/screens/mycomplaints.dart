import 'package:flutter/material.dart';

class MyComplaints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LimitedBox(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width,
        child: ListView.separated(
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 15,
              child: Center(
                child: Text("Complaint ${index + 1}",
                    style: Theme.of(context).textTheme.body1),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 2);
          },
        ),
      ),
    );
  }
}
