import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendToParentPage extends StatefulWidget {
  static const String routeName = '/send-to-parent';

  @override
  _SendToParentPageState createState() => _SendToParentPageState();
}

class _SendToParentPageState extends State<SendToParentPage> {
  late List<dynamic> parents;
  late List<dynamic> students;
  late int idUser;
  late int idEtablissement;
  dynamic selectedParent;
  dynamic selectedStudent;
  String recipientType = 'Aucun'; // Track the selected recipient type
  TextEditingController _messageController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      parents = args['parents'];
      students = args['students'];
      idUser = args['idUser'];
      idEtablissement = args['idEtablissement'];
    } else {
      // Handle the case where arguments are not provided
      parents = [];
      students = [];
      idUser = 0;
      idEtablissement = 0;
    }
  }

  void _selectParent() async {
    if (selectedStudent != null) {
      setState(() {
        selectedStudent = null; // Clear selected student if parent is selected
      });
    }

    final selected = await showSearch(
      context: context,
      delegate: ParentSearchDelegate(parents),
    );

    if (selected != null) {
      setState(() {
        selectedParent = selected;
      });
    }
  }

  void _selectStudent() async {
    if (selectedParent != null) {
      setState(() {
        selectedParent = null; // Clear selected parent if student is selected
      });
    }

    final selected = await showSearch(
      context: context,
      delegate: StudentSearchDelegate(students),
    );

    if (selected != null) {
      setState(() {
        selectedStudent = selected;
      });
    }
  }

  void _sendMessage() async {
    if (recipientType == 'Aucun') {
      _showError('Please select a recipient type.');
      return;
    }

    if (recipientType == 'Parent' && selectedParent == null) {
      _showError('Please select a parent.');
      return;
    }

    if (recipientType == 'Student' && selectedStudent == null) {
      _showError('Please select a student.');
      return;
    }

    final message = _messageController.text;

    final url = recipientType == 'Parent'
        ? 'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/send_select_parent.php'
        : 'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/send_select_student.php';

    final body = jsonEncode({
      'idUser': idUser,
      'idetablissement': idEtablissement,
      'message': message,
      if (recipientType == 'Parent') 'selectedParentId': selectedParent['id'],
      if (recipientType == 'Student')
        'selectedStudentId': selectedStudent['id'],
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseBody.containsKey('success')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Message envoyé', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (responseBody.containsKey('error')) {
        _showError(responseBody['error']);
      }
    } else {
      _showError('Failed to send message.');
    }

    _messageController.clear(); // Clear message field after sending
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Envoyer Message', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        color: Colors.grey[200], // Background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Instruction Text
            Text(
              'Sélectionner le type de destinataire',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            // DropdownButton for selecting recipient type
            DropdownButton<String>(
              value: recipientType,
              onChanged: (String? newValue) {
                setState(() {
                  recipientType = newValue ?? 'Aucun';
                  selectedParent = null; // Clear previous selections
                  selectedStudent = null;
                });
              },
              items: <String>['Aucun', 'Parent', 'Student']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    color: Colors
                        .transparent, // Background color of dropdown items
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      value,
                      style: TextStyle(
                          color:
                              Colors.blue[800]), // Text color of dropdown items
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (recipientType == 'Parent')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _selectParent,
                    child: Text('Search Parent',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700], // Background color
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(fontSize: 14), // Adjust font size
                    ),
                  ),
                  SizedBox(height: 20),
                  selectedParent == null
                      ? Text('No parent selected',
                          style: TextStyle(color: Colors.grey[600]))
                      : Text('Selected Parent: ${selectedParent['nomprenom']}',
                          style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            if (recipientType == 'Student')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _selectStudent,
                    child: Text('Search Student',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700], // Background color
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(fontSize: 14), // Adjust font size
                    ),
                  ),
                  SizedBox(height: 20),
                  selectedStudent == null
                      ? Text('No student selected',
                          style: TextStyle(color: Colors.grey[600]))
                      : Text(
                          'Selected Student: ${selectedStudent['nomprenom']}',
                          style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            SizedBox(height: 20),
            // Message TextField
            TextField(
              controller: _messageController,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                labelText: 'Type your message here',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            // Send Button
            ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(
                    vertical: 18, horizontal: 24), // Increased padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Adjust the border radius
                ),
                minimumSize: Size(double.infinity,
                    50), // Ensure button is at least this height
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20), // Add the icon
                  SizedBox(width: 10), // Space between the icon and text
                  Text('Envoyer',
                      style: TextStyle(fontSize: 16)), // Adjust font size
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParentSearchDelegate extends SearchDelegate<dynamic> {
  final List<dynamic> parents;

  ParentSearchDelegate(this.parents);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.blue[700]), // Change icon color
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon:
          Icon(Icons.arrow_back, color: Colors.blue[700]), // Change icon color
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = parents
        .where((parent) =>
            parent['nomprenom'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results.map<Widget>((parent) {
        return ListTile(
          title: Text(
            parent['nomprenom'],
            style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800]), // Adjust text size and color
          ),
          tileColor: Colors.blue[50], // Background color
          onTap: () {
            close(context, parent);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = parents
        .where((parent) =>
            parent['nomprenom'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions.map<Widget>((parent) {
        return ListTile(
          title: Text(
            parent['nomprenom'],
            style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800]), // Adjust text size and color
          ),
          tileColor: Colors.blue[50], // Background color
          onTap: () {
            close(context, parent);
          },
        );
      }).toList(),
    );
  }
}

class StudentSearchDelegate extends SearchDelegate<dynamic> {
  final List<dynamic> students;

  StudentSearchDelegate(this.students);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.blue[700]), // Change icon color
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon:
          Icon(Icons.arrow_back, color: Colors.blue[700]), // Change icon color
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = students
        .where((student) =>
            student['nomprenom'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results.map<Widget>((student) {
        return ListTile(
          title: Text(
            student['nomprenom'],
            style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800]), // Adjust text size and color
          ),
          tileColor: Colors.blue[50], // Background color
          onTap: () {
            close(context, student);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = students
        .where((student) =>
            student['nomprenom'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions.map<Widget>((student) {
        return ListTile(
          title: Text(
            student['nomprenom'],
            style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800]), // Adjust text size and color
          ),
          tileColor: Colors.blue[50], // Background color
          onTap: () {
            close(context, student);
          },
        );
      }).toList(),
    );
  }
}
