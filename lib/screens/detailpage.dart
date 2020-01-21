import 'package:pothole/provider/current_user_provider.dart';
import 'package:pothole/widgets/customtext_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isAuthority ;
  int _changedProgress;
  String _changedStatus = "Status";


  @override
  void initState() {
     super.initState();
    _initialize();
  }
 void _initialize(){
   isAuthority=Provider.of<CurrentUserProvider>(context).profile.role=="Civil Agency";
 }
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: _height * 0.35,
          width: _width,
          child: PageView.builder(
            itemBuilder: (context, index) {
              return Image.network(
                "https://images.unsplash.com/photo-1579616138977-5370304f898e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=889&q=80",
                fit: BoxFit.fill,
              );
            },
          ),
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Place", style: Theme.of(context).textTheme.subhead),
            IconButton(
              icon: Icon(
                Icons.room,
                color: Colors.blue,
              ),
              onPressed: () => openMap(40.0, 41.05),
            ),
          ],
        ),
        SizedBox(height: 10),
        CustomTextView(
            text:
                "The red-tailed tropicbird is a seabird native to the tropical Indian and Pacific Oceans. One of three closely related species of tropicbird, it has four subspecies. Text wrapping is quite a pain for me too. I find that putting Text in a Container and then wrapping that container in a Expanded/Flexible works well."),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: _height * 0.05,
              width: _height * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue),
              ),
              child: Center(
                  child: Text(
                "50 %",
                style: TextStyle(color: Colors.blue),
              )),
            ),
            !isAuthority
                ? Text(
                    "Progress",
                    style: Theme.of(context).textTheme.subhead,
                  )
                : _progressDown(),
            !isAuthority
                ? Text(
                    "Status",
                    style: Theme.of(context).textTheme.subhead,
                  )
                : _statusDown(),
          ],
        )
      ],
    ));
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  DropdownButton _progressDown() => DropdownButton<int>(
        hint: Text("Progress"),
        icon: Icon(Icons.arrow_drop_down),
        items: [
          DropdownMenuItem(
            value: 1,
            child: Text(
              "0",
            ),
          ),
          DropdownMenuItem(
            value: 2,
            child: Text(
              "25",
            ),
          ),
          DropdownMenuItem(
            value: 3,
            child: Text(
              "50",
            ),
          ),
          DropdownMenuItem(
            value: 4,
            child: Text(
              "75",
            ),
          ),
          DropdownMenuItem(
            value: 5,
            child: Text(
              "100",
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _changedProgress = value;
          });
        },
        value: _changedProgress,
      );

  DropdownButton _statusDown() => DropdownButton<String>(
        hint: Text("Status"),
        icon: Icon(Icons.arrow_drop_down),
        items: [
          DropdownMenuItem(
            value: "1",
            child: Text(
              "Pending",
            ),
          ),
          DropdownMenuItem(
            value: "2",
            child: Text(
              "In Progress",
            ),
          ),
          DropdownMenuItem(
            value: "3",
            child: Text(
              "Complete",
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _changedStatus = value;
          });
        },
        value: _changedStatus,
      );
}
