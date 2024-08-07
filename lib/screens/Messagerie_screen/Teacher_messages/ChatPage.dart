import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
/*
class ChatTeacherPage extends StatefulWidget {
  static const String routeName = '/ChatTeacherPage';

  @override
  _ChatTeacherPageState createState() => _ChatTeacherPageState();
}

class _ChatTeacherPageState extends State<ChatTeacherPage> {
  late int idSource;
  late int selectedParentId;
  late int idUser;
  List<dynamic> conversation = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController messageController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      idSource = arguments['idSource'] ?? 0;
      selectedParentId = arguments['selectedParentId'] ?? 0;
      idUser = arguments['idUser'] ?? 0;
      fetchConversation();
    } else {
      setState(() {
        errorMessage = 'Invalid parameters';
        isLoading = false;
      });
    }
  }

  Future<void> fetchConversation() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_conversation_Teacher.php'),
        body: json.encode({'idSource': idSource}),
        headers: {"Content-Type": "application/json"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        setState(() {
          conversation = json.decode(response.body) ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load conversation';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage() async {
    final String url =
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/send_to_parent.php';
    final String message = messageController.text;

    if (message.isEmpty) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'idUser': idUser,
          'selectedParentId': selectedParentId,
          'message': message,
          'idsource': idSource,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Print the raw response

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] != null) {
          setState(() {
            conversation.add({
              'mail': message,
              'nomprenom': 'Moi',
              'dateheure': DateTime.now().toString(),
            });
            messageController.clear();
          });
        } else {
          setState(() {
            errorMessage = jsonResponse['error'] ?? 'Failed to send message';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to send message';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Teacher'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: conversation.length,
                        itemBuilder: (context, index) {
                          final message = conversation[index];
                          String messageText = message['mail'] ?? 'No message';
                          String senderName = message['nomprenom'] ?? 'Unknown';
                          return ListTile(
                            title: Text(messageText),
                            subtitle: Text('From: $senderName'),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          CircleAvatar(
                            backgroundColor: Colors.blue[800],
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white),
                              onPressed: sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatTeacherPage extends StatefulWidget {
  static const routeName = 'chatTeacherPage';

  @override
  _ChatTeacherPageState createState() => _ChatTeacherPageState();
}

class _ChatTeacherPageState extends State<ChatTeacherPage> {
  late int idSource;
  late int idUser;
  late int selectedParentId;
  List<Map<String, dynamic>> conversation = [];
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        setState(() {
          idSource = args['idSource'] as int? ?? 0;
          idUser = args['idUser'] as int? ?? 0;
          selectedParentId = args['selectedParentId'] as int? ?? 0;
        });
        fetchConversation(idSource);
      }
    });
  }

  void fetchConversation(int idSource) async {
    String url =
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_conversation_Teacher.php';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idSource': idSource}),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          conversation = List<Map<String, dynamic>>.from(jsonData);
        });
      } else {
        print('Failed to load conversation');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void sendMessage() async {
    String url =
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/send_to_parent.php';
    String message = messageController.text;

    if (message.isEmpty) {
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idUser': idUser,
          'selectedParentId': selectedParentId,
          'message': message,
          'idsource': idSource
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['success'] != null) {
          setState(() {
            conversation.add({
              'nomprenom': 'Moi',
              'mail': message,
              'dateheure': DateTime.now().toString(),
              'idsource': idSource
            });
            messageController.clear();
          });
        } else {
          print('Failed to send message');
        }
      } else {
        print('Failed to send message');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Teacher'),
        backgroundColor: Colors.blue[800],
      ),
      body: conversation.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: conversation.length,
                    itemBuilder: (context, index) {
                      final message = conversation[index];
                      bool isMe = message['nomprenom'] == 'Moi';
                      String senderName =
                          isMe ? 'Moi' : '${message['nomprenom'] ?? ''}';
                      Color? bubbleColor =
                          isMe ? Colors.blue[100] : Colors.grey[200];
                      Color textColor = isMe ? Colors.black : Colors.black87;
                      Alignment alignment =
                          isMe ? Alignment.centerRight : Alignment.centerLeft;

                      return Align(
                        alignment: alignment,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                              bottomLeft: isMe
                                  ? Radius.circular(16.0)
                                  : Radius.circular(0),
                              bottomRight: isMe
                                  ? Radius.circular(0)
                                  : Radius.circular(16.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                message['mail'] ?? '',
                                style: TextStyle(color: textColor),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                message['dateheure'] ?? '',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      CircleAvatar(
                        backgroundColor: Colors.blue[800],
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
