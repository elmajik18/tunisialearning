import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/Messagerie_screen/Teacher_messages/ChatPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/Messagerie_screen/Teacher_messages/ChatPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_nav_bar/google_nav_bar.dart';

class TeacherMessagingPage extends StatefulWidget {
  static const String routeName = '/teacher-messaging';

  @override
  _TeacherMessagingPageState createState() => _TeacherMessagingPageState();
}

class _TeacherMessagingPageState extends State<TeacherMessagingPage> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late int idUser;
  late int idEtablissement;
  List<dynamic> _parents = [];
  List<dynamic> _students = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      if (arguments != null &&
          arguments['iduser'] != null &&
          arguments['idetablissement'] != null) {
        idUser = arguments['iduser'];
        idEtablissement = arguments['idetablissement'];
        _fetchParents();
        _fetchStudents();
        _fetchMessages();
      } else {
        setState(() {
          _errorMessage = 'Invalid parameters';
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _updateMessageStatus(int messageId, int lu) async {
    final url =
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/update_lu_state.php';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'messageId': messageId,
      'lu': lu,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          print('Message status updated successfully.');
        } else {
          print('Failed to update message status: ${responseBody['message']}');
        }
      } else {
        print(
            'Failed to update message status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchParents() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_all_parents.php?idetablissement=$idEtablissement'));
      print('Parents response status: ${response.statusCode}');
      print('Parents response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> parents = json.decode(response.body);
        print('Decoded parents: $parents');

        setState(() {
          _parents = parents;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load parents. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_all_students.php?idetablissement=$idEtablissement'));
      print('Students response status: ${response.statusCode}');
      print('Students response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> students = json.decode(response.body);
        print('Decoded students: $students');

        setState(() {
          _students = students;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load students. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_parents_messages.php?iduser=$idUser&idetablissement=$idEtablissement'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> messages = json.decode(response.body);
        print('Decoded messages: $messages');

        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load messages. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.blue[800],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Messages",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    String messagePreview = message['mail'].length > 50
                        ? '${message['mail'].substring(0, 50)}...'
                        : message['mail'];
                    bool isUnseen = message['lu'] == '1';
                    bool isMoi = message['sender_name'] == 'Moi';

                    return GestureDetector(
                      onTap: () async {
                        if (!isMoi && isUnseen) {
                          await _updateMessageStatus(
                              int.parse(message['id']), 0); // Mark as seen
                        }

                        Navigator.pushNamed(
                          context,
                          ChatTeacherPage.routeName,
                          arguments: {
                            'idSource': int.parse(message['idsource']),
                            'selectedParentId': int.parse(message['idsender']),
                            'idUser': idUser,
                          },
                        );
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUnseen ? Colors.blue[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${message['sender_name']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    messagePreview,
                                    style: TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${message['dateheure']}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Icon(
                                        Icons.mail,
                                        color: isMoi
                                            ? Colors.grey
                                            : isUnseen
                                                ? Colors.red
                                                : Colors.green,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/send-to-parent', // Replace with your route for the message sending page
            arguments: {
              'students': _students,
              'parents': _parents,
              'idUser': idUser,
              'idEtablissement': idEtablissement,
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
        elevation: 8.0,
        tooltip: 'Send a new message',
      ),
    );
  }
}
