import 'package:flutter/material.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:flutter_first_project/screens/login_screen/login_screen.dart';


import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_first_project/constante.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmploiDuTempsScreen extends StatelessWidget {
  static const routeName = 'EmploiDuTempsScreen';
  static const String baseUrl = 'https://www.ibnkhaldoun.tunisia-learning.com/';

  Future<List<Map<String, dynamic>>> fetchEmploiDuTemps(
      String idEtablissement, String idNiveau, String idClasse) async {
    final Uri uri = Uri.parse(
            'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_emploi_child.php')
        .replace(
      queryParameters: {
        'idetablissement': idEtablissement,
        'idniveau': idNiveau,
        'idclasse': idClasse,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        List<dynamic> data = responseData['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('No records found with the given criteria');
      }
    } else {
      throw Exception('Failed to load schedule');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Error: No data provided.'),
        ),
      );
    }

    final String idEtablissement = args['idetablissement'];
    final String idNiveau = args['idniveau'];
    final String idClasse = args['idclasse'];

    Future<List<Map<String, dynamic>>> futureEmploiDuTemps =
        fetchEmploiDuTemps(idEtablissement, idNiveau, idClasse);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Emploi du Temps',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
                color: Colors.white,
              ),
        ),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureEmploiDuTemps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No schedule found'),
            );
          }

          var scheduleData = snapshot.data!;

          return ListView.builder(
            itemCount: scheduleData.length,
            itemBuilder: (context, index) {
              var schedule = scheduleData[index];
              String pdfUrl = baseUrl + schedule['pdf'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  title: Text(
                    'Schedule ID: ${schedule['id']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'PDF URL: ${schedule['pdf']}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.open_in_new, color: Colors.blue),
                    onPressed: () async {
                      if (await canLaunch(pdfUrl)) {
                        await launch(pdfUrl);
                      } else {
                        throw 'Could not launch $pdfUrl';
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
