import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/login_screen/login_screen.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/login_screen/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocScreen extends StatefulWidget {
  static const routeName = 'DocScreen';
  final int idEtablissement;
  final int idNiveau;
  final int idClasse;

  DocScreen({
    required this.idEtablissement,
    required this.idNiveau,
    required this.idClasse,
  });

  @override
  _DocScreenState createState() => _DocScreenState();
}

class _DocScreenState extends State<DocScreen> {
  late Future<List<Document>> futureDocuments;

  @override
  void initState() {
    super.initState();
    futureDocuments = fetchDocuments(
      widget.idEtablissement,
      widget.idNiveau,
      widget.idClasse,
    );
  }

  Future<List<Document>> fetchDocuments(
      int idEtablissement, int idNiveau, int idClasse) async {
    final baseUrl =
         'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_doc.php?idetablissement=$idEtablissement&idniveau=$idNiveau&idclasse=$idClasse';
        //'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_doc.php?idetablissement=2&idniveau=1&idclasse=0';

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes).trim();
      List<dynamic> jsonResponse = json.decode(responseBody);

      return jsonResponse.map((doc) => Document.fromJson(doc)).toList();
    } else {
      throw Exception('Failed to load documents: ${response.statusCode}');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Documents',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
        ),
        backgroundColor: Colors.blueAccent, // Adjust as needed
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'logout') {
                  // Handle logout action
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
        child: FutureBuilder<List<Document>>(
          future: futureDocuments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Aucun document pour le moment !"));
            } else {
              List<Document> documents = snapshot.data!;
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  Document document = documents[index];
                  return Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white, // Card background color
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.file_present,
                            size: 40,
                            color: Colors.blueAccent, // Icon color
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*Text(
                                  document.titre,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),*/
                                SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    String fullUrl =
                                        'https://www.ibnkhaldoun.tunisia-learning.com/${document.document}';
                                    _launchURL(fullUrl); // Launch URL on tap
                                  },
                                  child: Text(
                                    'Appuyer pour télécharger',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class Document {
  //final String titre;
  final String document;

  Document({required this.document});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      // titre: json['titre'],
      document: json['document'],
    );
  }
}
