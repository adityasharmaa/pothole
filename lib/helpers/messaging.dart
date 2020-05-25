import 'dart:async';
import 'dart:convert' show json;

import 'package:http/http.dart' as http;

class Messaging {
  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    print("background: $message");
  }

  static Future<String> sendNotification({String topic,String title, String body, String image, String complaintId}) async{
    final serverToken = "AAAAF9NEt4E:APA91bFEVjhIWGRk-B5BvVEH6NXjIAF0deXnxLba3BfOf0yAvOqR5_FpPvwmUQZty4CVc-rQYpLtL0oni80DC87gdcaQSiHwNczoe0antT9ivMH6RFYU1Ty-vUlfj3dn-NQ-35GEAnDe";

    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: json.encode(
        {
          'notification': {
            'body': body,
            'title': title,
            'image': image
          },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'image': image,
            'complaint_id': complaintId
          },
          'to': "/topics/$topic"
        },
      ),
    );

    print("Response: ${response.body}");

    return response.body;
  }
}
