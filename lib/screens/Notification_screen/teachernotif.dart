import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherNotifScreen extends StatelessWidget {
  static String routeName = 'TeacherNotifScreen';

  Future<Map<String, dynamic>> fetchNotifications(String id) async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_notification_mssg.php?iduser=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String id = args['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Notifications'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchNotifications(id),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return Center(
              child: Text(data['message'] ?? 'No message received.'),
            );
          } else {
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}
