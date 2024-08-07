import 'package:http_parser/http_parser.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:flutter_first_project/screens/data/course_model.dart';
import 'package:flutter_first_project/screens/login_screen/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

String getContentType(String? extension) {
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'pdf':
      return 'application/pdf';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    default:
      return 'application/octet-stream';
  }
}

class CourseScreen extends StatefulWidget {
  static const routeName = 'CourseScreen';
  final int idEtablissement;
  final int idNiveau;
  final int idClasse;
  final int idEleve;

  CourseScreen({
    required this.idEtablissement,
    required this.idNiveau,
    required this.idClasse,
    required this.idEleve,
  });

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late Future<List<Course>> futureCourses;

  @override
  void initState() {
    super.initState();
    futureCourses = fetchCourses(
      widget.idEtablissement,
      widget.idNiveau,
      widget.idClasse,
    );
  }

  Future<List<Course>> fetchCourses(
      int idEtablissement, int idNiveau, int idClasse) async {
    final baseUrl =
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_exercours.php?idetablissement=$idEtablissement&idniveau=$idNiveau&idclasse=$idClasse';

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes).trim();
      List<dynamic> jsonResponse = json.decode(responseBody);
      return jsonResponse.map((course) => Course.fromJson(course)).toList();
    } else {
      throw Exception('Failed to load courses: ${response.statusCode}');
    }
  }

  // Function to launch URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Color getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'قراءة وفهم':
        return Colors.green;
      case 'الرياضيات':
        return Colors.orange;
      case 'التاريخ':
        return Colors.blue;
      case 'anglais':
        return Colors.purple;
      case 'production écrite':
        return Color.fromARGB(255, 67, 4, 139);
      case 'lecture et compréhension':
        return Color.fromARGB(255, 237, 229, 4);
      case 'قواعد لغة':
        return Color.fromARGB(255, 182, 4, 43);
      default:
        return Color.fromARGB(255, 1, 84, 33);
    }
  }

  // Function to show success message
  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.sentiment_very_satisfied, color: Colors.white),
            SizedBox(width: 8),
            Text('Bravo !', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4), // Increase duration
      ),
    );
  }

  String getContentType(String? extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      // Add other cases as needed
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _pickFile(int idcours) async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        if (file.bytes != null) {
          final uri = Uri.parse(
              'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/upload_response.php');

          final request = http.MultipartRequest('POST', uri)
            ..fields['idcours'] = idcours.toString() // Replace with actual data
            ..fields['idetablissement'] =
                widget.idEtablissement.toString() // Replace with actual data
            ..fields['ideleve'] =
                widget.idEleve.toString() // Replace with actual data
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                file.bytes!,
                filename: file.name,
                contentType: file.extension != null
                    ? MediaType.parse(getContentType(file.extension))
                    : MediaType.parse('application/octet-stream'),
              ),
            );

          final response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final result = json.decode(responseBody);

            if (result['status'] == 'success') {
              _showSuccessSnackBar();
            } else {
              print('Error: ${result['message']}');
            }
          } else {
            print('Error: ${response.statusCode}');
          }
        } else {
          print('File bytes are null.');
        }
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cours et Exercices',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
                color: Colors.white,
              ),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'logout') {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.routeName, (route) => false);
                }
              },
              offset: Offset(0, 50),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black54),
                      SizedBox(width: 10),
                      Text('Déconnexion'),
                    ],
                  ),
                ),
              ],
              icon: Icon(
                Icons.account_circle_sharp,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Course>>(
          future: futureCourses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No courses available."));
            } else {
              List<Course> courses = snapshot.data!;
              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  Course course = courses[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.matiere,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: getSubjectColor(course.matiere),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Teacher: ${course.enseignant}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Type: ${course.type}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Date: ${course.date}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 12),
                          Divider(color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Documents:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Appuyer sur les documents ci-dessous pour les télécharger',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: course.documents.map((document) {
                              return InkWell(
                                onTap: () {
                                  String fullUrl =
                                      'https://www.ibnkhaldoun.tunisia-learning.com/${document.document}';
                                  _launchURL(fullUrl); // Launch URL on tap
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.file_present,
                                      size: 40,
                                      color: getSubjectColor(course.matiere),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      document.titre,
                                      style: TextStyle(
                                        color: getSubjectColor(course.matiere),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                          if (course.type.toLowerCase() == 'exercice') ...[
                            Text(
                              'Veuillez soumettre votre devoir :',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _pickFile(course.idcours),
                              icon: Icon(Icons.upload_file),
                              label: Text('Choisir un fichier'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 115, 173, 219), // Background color
                              ),
                            ),
                            /* ElevatedButton(
                              onPressed: _pickFile,
                              child: Text('Choisir un fichier'),
                            ),*/
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
