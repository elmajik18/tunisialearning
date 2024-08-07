import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AbscenceScreen extends StatefulWidget {
  static String routeName = 'AbscenceScreen';

  @override
  _AbscenceScreenState createState() => _AbscenceScreenState();
}

class _AbscenceScreenState extends State<AbscenceScreen> {
  int? idUser;
  int? idEtablissement;
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Retrieve arguments from the navigator
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      idUser = args['iduser'];
      idEtablissement = args['idetablissement'];
    });
  }

  Future<void> _sendAbsenceRequest() async {
    final String url =
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/send_abscence.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'idenseignant': idUser,
          'observation': _observationController.text,
          'idetablissement': idEtablissement,
          'date': _dateController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Demande d\'absence envoyée avec succès !'),
              backgroundColor: Colors.blue[800],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Échec de l\'envoi de la demande : ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'La demande a échoué avec le statut: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur s\'est produite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:
                Colors.blue[800], // Blue color for the header and buttons
            // Styling for calendar and date selection
            dialogBackgroundColor: Colors.white,
            textTheme: TextTheme(
              titleLarge:
                  TextStyle(color: Colors.black), // Black color for date text
              bodyMedium:
                  TextStyle(color: Colors.black), // Black color for body text
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.blue[800], // Blue color for buttons
            ),
            // Styling for input fields
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Demande d\'Absence',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue[800],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Bienvenue',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Veuillez remplir les détails ci-dessous pour soumettre votre demande d\'absence.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.blue[800]),
            SizedBox(height: 20),
            Text(
              'Observation:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _observationController,
              maxLines: 4,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Entrez votre observation ici',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Date:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'YYYY-MM-DD',
                hintStyle: TextStyle(color: Colors.grey[600]),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.blue[800]),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _sendAbsenceRequest,
                child: Text(
                  'Envoyer',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                'Merci de votre coopération!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
