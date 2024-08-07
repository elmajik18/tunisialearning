import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RatrapageScreen extends StatefulWidget {
  static String routeName = 'RatrapageScreen';

  @override
  _RatrapageScreenState createState() => _RatrapageScreenState();
}

class _RatrapageScreenState extends State<RatrapageScreen> {
  int? idUser;
  int? idEtablissement;
  int? selectedMatiere;
  int? selectedNiveau;
  int? selectedClasse;
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<dynamic> matieres = [];
  List<dynamic> niveaux = [];
  List<dynamic> classes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Retrieve arguments from the navigator
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      idUser = args['iduser'];
      idEtablissement = args['idetablissement'];
      // Fetch initial data
      fetchMatieres();
    });
  }

  Future<void> submitRatrapage() async {
    if (selectedMatiere == null ||
        selectedNiveau == null ||
        selectedClasse == null ||
        idEtablissement == null ||
        _observationController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      // Display an error message if any required field is missing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(
          'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/send_ratrappage.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idenseignant': idUser,
        'idniveau': selectedNiveau,
        'idmatiere': selectedMatiere,
        'idclasse': selectedClasse,
        'date': _dateController.text,
        'heure': _timeController.text,
        'observation': _observationController.text,
        'idetablissement': idEtablissement,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande de ratrapage envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally clear the form or navigate away
        setState(() {
          selectedMatiere = null;
          selectedNiveau = null;
          selectedClasse = null;
          _observationController.clear();
          _dateController.clear();
          _timeController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Échec de l\'envoi de la demande : ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur s\'est produite'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchMatieres() async {
    final response = await http.get(Uri.parse(
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_all_matiére.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          matieres = data['data'].map((item) {
            item['id'] =
                int.tryParse(item['id'].toString()); // Convert ID to integer
            return item;
          }).toList();
        });
      }
    }
  }

  Future<void> fetchNiveaux(int idEtablissement) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_all_niveaux.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idetablissement': idEtablissement}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          niveaux = data['data'].map((item) {
            item['id'] =
                int.tryParse(item['id'].toString()); // Convert ID to integer
            return item;
          }).toList();
        });
      }
    }
  }

  Future<void> fetchClasses(int idNiveau, int idEtablissement) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_all_classes.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'idniveau': idNiveau, 'idetablissement': idEtablissement}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          classes = data['data'].map((item) {
            item['id'] =
                int.tryParse(item['id'].toString()); // Convert ID to integer
            return item;
          }).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Demande de Rattrapage',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue[800],
      ),
      backgroundColor: Colors.grey[100], // Light grey background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veuillez compléter les informations suivantes:',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Colors.blueGrey[800],
                  ),
            ),
            SizedBox(height: 20),
            _buildDropdown(
              items: matieres,
              value: selectedMatiere,
              hint: 'Sélectionnez Matière',
              onChanged: (int? newValue) {
                setState(() {
                  selectedMatiere = newValue;
                  if (idEtablissement != null) {
                    fetchNiveaux(idEtablissement!);
                  }
                });
              },
              itemBuilder: (context, item) => Text(
                item['matiere'],
                style: TextStyle(color: Colors.black), // Changed to black
              ),
            ),
            SizedBox(height: 20),
            _buildDropdown(
              items: niveaux,
              value: selectedNiveau,
              hint: 'Sélectionnez Niveau',
              onChanged: (int? newValue) {
                setState(() {
                  selectedNiveau = newValue;
                  if (selectedNiveau != null && idEtablissement != null) {
                    fetchClasses(selectedNiveau!, idEtablissement!);
                  }
                });
              },
              itemBuilder: (context, item) => Text(
                item['niveau'],
                style: TextStyle(color: Colors.black), // Changed to black
              ),
            ),
            SizedBox(height: 20),
            _buildDropdown(
              items: classes,
              value: selectedClasse,
              hint: 'Sélectionnez Classe',
              onChanged: (int? newValue) {
                setState(() {
                  selectedClasse = newValue;
                });
              },
              itemBuilder: (context, item) => Text(
                item['classe'],
                style: TextStyle(color: Colors.black), // Changed to black
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Observation:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
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
                hintStyle:
                    TextStyle(color: Colors.grey[600]), // Light grey hint text
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Date:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'jj/mm/aaaa',
                hintStyle:
                    TextStyle(color: Colors.grey[600]), // Light grey hint text
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 20),
            Text(
              'Heure:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'hh:mm',
                hintStyle:
                    TextStyle(color: Colors.grey[600]), // Light grey hint text
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: submitRatrapage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800], // Button color
                  minimumSize: Size(200, 45), // Adjust size here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 15), // Adjust padding here
                ),
                child: Text(
                  'Soumettre',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required List<dynamic> items,
    required int? value,
    required String hint,
    required void Function(int?) onChanged,
    required Widget Function(BuildContext, dynamic) itemBuilder,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      hint: Text(hint),
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: itemBuilder(context, item),
        );
      }).toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
