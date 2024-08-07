import 'package:flutter/material.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:flutter_first_project/screens/home_screen/home_screen.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyProfileScreen extends StatefulWidget {
  static const String routeName = 'MyProfileScreen';

  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late Map<String, dynamic> teacherDetails;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController adresseController;
  late TextEditingController dateNaissanceController;
  late TextEditingController lieuNaissanceController;
  late String id;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    teacherDetails = {};
    emailController = TextEditingController();
    telephoneController = TextEditingController();
    adresseController = TextEditingController();
    dateNaissanceController = TextEditingController();
    lieuNaissanceController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    id = args?['id'] ?? '';
    fetchTeacherDetails();
  }

  @override
  void dispose() {
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    dateNaissanceController.dispose();
    lieuNaissanceController.dispose();
    super.dispose();
  }

  Future<void> fetchTeacherDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_profil_teacher.php?id=$id'),
      );

      if (response.statusCode == 200) {
        setState(() {
          teacherDetails = json.decode(response.body)['data'];
          emailController.text = teacherDetails['email'] ?? '';
          telephoneController.text = teacherDetails['telephone'] ?? '';
          adresseController.text = teacherDetails['adresse'] ?? '';
          dateNaissanceController.text = teacherDetails['date_naissance'] ?? '';
          lieuNaissanceController.text = teacherDetails['lieu_naissance'] ?? '';
          selectedDate =
              DateTime.tryParse(teacherDetails['date_naissance'] ?? '');
        });
      } else {
        throw Exception('Failed to load teacher details');
      }
    } catch (e) {
      print('Exception while fetching teacher details: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 73, 172, 76),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF345FB4),
              onPrimary: Colors.white,
              onSurface: Color(0xFF313131),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF345FB4),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateNaissanceController.text =
            "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mon Profil',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 12.sp,
            )),
        actions: [
          InkWell(
            onTap: () {
              print('Sending report to school management');
            },
            child: Container(
              padding: EdgeInsets.only(right: kDefaultPadding / 2),
              child: Row(
                children: [
                  Icon(Icons.report_gmailerrorred_outlined,
                      color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Report',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: kOtherColor,
        child: ListView(
          padding: EdgeInsets.all(kDefaultPadding),
          children: [
            Container(
              width: double.infinity,
              height: SizerUtil.deviceType == DeviceType.tablet ? 15.h : 12.h,
              decoration: BoxDecoration(
                color: Color(0xFF345FB4),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius:
                        SizerUtil.deviceType == DeviceType.tablet ? 10.w : 8.w,
                    backgroundColor: Color.fromARGB(255, 229, 231, 196),
                    backgroundImage:
                        AssetImage('assets/images/teacher_profil.png'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${teacherDetails['nom']} ${teacherDetails['prenom']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            ProfileDetailRow(
              title: 'Nom',
              value: teacherDetails['nom'] ?? '',
              editable: true,
            ),
            ProfileDetailRow(
              title: 'Prénom',
              value: teacherDetails['prenom'] ?? '',
              editable: true,
            ),
            ProfileDetailRow(
              title: 'Date de naissance',
              value: selectedDate != null
                  ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                  : 'Select date',
              editable: true,
              icon: Icons.calendar_today,
              onIconTap: () => _selectDate(context),
            ),
            ProfileDetailRow(
              title: 'Lieu de naissance',
              value: teacherDetails['lieu_naissance'] ?? '',
              editable: true,
            ),
            SizedBox(height: 15),
            ProfileDetailColumn(
              title: 'Email',
              value: teacherDetails['email'] ?? '',
              editable: true,
            ),
            ProfileDetailColumn(
              title: 'Mot de passe',
              value: teacherDetails['motdepasse'] ?? '',
              editable: false,
            ),
            ProfileDetailColumn(
              title: 'Téléphone',
              value: teacherDetails['telephone'] ?? '',
              editable: true,
            ),
            ProfileDetailColumn(
              title: 'Adresse',
              value: teacherDetails['adresse'] ?? '',
              editable: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSnackBar(context, 'Changes saved successfully');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF345FB4),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                'Enregistrer',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatefulWidget {
  const ProfileDetailRow({
    Key? key,
    required this.title,
    required this.value,
    this.icon,
    this.onIconTap,
    this.editable = true,
  }) : super(key: key);
  final String title;
  final String value;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final bool editable;

  @override
  State<ProfileDetailRow> createState() => _ProfileDetailRowState();
}

class _ProfileDetailRowState extends State<ProfileDetailRow> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                _isEditing
                    ? TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        widget.value,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                        ),
                      ),
              ],
            ),
          ),
          if (widget.editable)
            IconButton(
              icon: Icon(widget.icon ?? Icons.edit, color: Colors.black),
              onPressed: widget.onIconTap,
            ),
        ],
      ),
    );
  }
}

class ProfileDetailColumn extends StatelessWidget {
  final String title;
  final String value;
  final bool editable;

  const ProfileDetailColumn({
    Key? key,
    required this.title,
    required this.value,
    this.editable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          if (editable)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}
