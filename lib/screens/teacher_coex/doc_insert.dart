import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// API Service class
class ApiService {
  final String baseUrl = 'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/';  // Update with your server URL

  Future<Map<String, dynamic>?> fetchData(int idUser) async {
    final response = await http.get(Uri.parse('$baseUrl/your-script.php?id=$idUser'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

// Main screen class
class InsertDocScreen extends StatefulWidget {
  static const routeName = '/insert-doc';

  @override
  _InsertDocScreenState createState() => _InsertDocScreenState();
}

class _InsertDocScreenState extends State<InsertDocScreen> {
  late Future<Map<String, dynamic>?> _data;
  final ApiService apiService = ApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the arguments passed to this route
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final idUser = args['iduser'] as int;

    // Fetch data when the widget is initialized
    _data = apiService.fetchData(idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Document'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            final data = snapshot.data!;
            final idetablissement = data['idetablissement'];
            final nomprenom = data['nomprenom'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('ID Etablissement: $idetablissement', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Text('Nom Prenom: $nomprenom', style: TextStyle(fontSize: 18)),
                  // Add more widgets to display the data as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
