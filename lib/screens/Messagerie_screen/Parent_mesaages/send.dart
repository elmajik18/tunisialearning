import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/Messagerie_screen/Parent_Messagerie_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageSendingPage extends StatefulWidget {
  static const routeName = '/sendMessagePage';

  @override
  _MessageSendingPageState createState() => _MessageSendingPageState();
}

class _MessageSendingPageState extends State<MessageSendingPage> {
  late String _selectedRecipientType;
  Teacher? _selectedTeacher;
  String? _selectedChild;
  TextEditingController _messageController = TextEditingController();
  int? idUser;
  int? idEtablissement;

  @override
  void initState() {
    super.initState();
    _selectedRecipientType = 'Enseignant'; // Default recipient type
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null ||
        args['childrenNames'] == null ||
        args['filteredTeachers'] == null ||
        args['id'] == null ||
        args['idEtablissement'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Error: Missing parameters.'),
        ),
      );
    }

    List<String> childrenNames = args['childrenNames'];
    List<Teacher> filteredTeachers = args['filteredTeachers'];
    idUser = args['id'];
    idEtablissement = args['idEtablissement'];

    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      appBar: AppBar(
        title: Text('Send Message'),
        backgroundColor: const Color.fromARGB(255, 21, 63, 137),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Compose your message',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRecipientType,
              decoration: InputDecoration(
                labelText: 'Recipient type',
                border: OutlineInputBorder(),
              ),
              items: ['Enseignant', 'Other Type'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRecipientType = value!;
                  _selectedTeacher =
                      null; // Reset selected teacher on type change
                });
              },
            ),
            SizedBox(height: 20),
            if (_selectedRecipientType == 'Enseignant') ...[
              DropdownButtonFormField<Teacher>(
                decoration: InputDecoration(
                  labelText: "Select a teacher",
                  border: OutlineInputBorder(),
                ),
                value: _selectedTeacher,
                items: filteredTeachers.map((Teacher teacher) {
                  return DropdownMenuItem<Teacher>(
                    value: teacher,
                    child: Text(
                      teacher.fullName,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTeacher = value;
                  });
                },
              ),
              SizedBox(height: 20),
            ],
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select child",
                border: OutlineInputBorder(),
              ),
              value: _selectedChild,
              items: childrenNames.map((String child) {
                return DropdownMenuItem<String>(
                  value: child,
                  child: Text(
                    child,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChild = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              style: TextStyle(color: Colors.black),
              maxLines: null, // Unlimited lines
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 44, 50, 202),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Envoyer'), // Changed the label to 'Envoyer'
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (_selectedTeacher == null && _selectedRecipientType == 'Enseignant') {
      _showErrorDialog('Please select a teacher.');
      return;
    }
    if (_selectedChild == null) {
      _showErrorDialog('Please select a child.');
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a message.');
      return;
    }

    // Extract the teacher ID and other necessary data
    String teacherId =
        _selectedTeacher?.id ?? ''; // Safe navigation to access id
    String teacherName =
        _selectedTeacher?.fullName ?? ''; // Safe navigation to access fullName

    // Implement the logic to send the message here, including idUser and idEtablissement
    int selectedTeacherId = int.parse(teacherId); // Parse teacherId to int

    bool isSuccess = await sendMessage(
        idUser!, selectedTeacherId, _messageController.text.trim());
    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message envoyé avec succès !'),
          backgroundColor: const Color.fromARGB(255, 54, 175, 58),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(); // Close the page after sending
    } else {
      _showErrorDialog('Failed to send message. Please try again.');
    }
  }

  Future<bool> sendMessage(
      int idUser, int selectedTeacherId, String message) async {
    final url = Uri.parse(
        'http://localhost:8080//Tunisia_Learning_backend/TunisiaLearningPhp/send_select_teacher.php');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "idUser": idUser,
      "selectedTeacherId": selectedTeacherId,
      "message": message,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Message sent successfully");
      return true;
    } else {
      print("Error sending message: ${response.body}");
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
