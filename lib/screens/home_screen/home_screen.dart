import 'dart:ui';
import 'package:flutter_first_project/components/side_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_first_project/components/side_menu.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:flutter_first_project/screens/Messagerie_screen/Parent_Messagerie_screen.dart';
import 'package:flutter_first_project/screens/Messagerie_screen/Teacher_Messagerie_screen.dart';
import 'package:flutter_first_project/screens/Messagerie_screen/Teacher_messages/Abscence_Demande/Abscence.dart';
import 'package:flutter_first_project/screens/Messagerie_screen/Teacher_messages/Ratrapage_Demande/Ratrapage_Demande.dart';
import 'package:flutter_first_project/screens/Notification_screen/teachernotif.dart';
import 'package:flutter_first_project/screens/login_screen/login_screen.dart';

import 'package:flutter_first_project/screens/my_profile/my_profile.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<TeacherDetails?> _teacherDetailsFuture;
  late Future<int> _notificationCountFuture;
  late String id;
  late String nom;
  late String prenom;

  @override
  void initState() {
    super.initState();
    _teacherDetailsFuture = Future.value(null);
    _notificationCountFuture = fetchNotificationCount();
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Receive arguments from LoginScreen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    id = args['id'] ?? '';
    nom = args['nom'] ?? '';
    prenom = args['prenom'] ?? '';
    _teacherDetailsFuture = fetchTeacherDetails();
    _notificationCountFuture = fetchNotificationCount();
  }

  Future<int> fetchNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8080//Tunisia_Learning_backend/TunisiaLearningPhp/get_notification_mssg.php?iduser=1'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception('Failed to load notification count');
      }
    } catch (e) {
      print('Error fetching notification count: $e');
      return 0;
    }
  }

  Future<TeacherDetails?> fetchTeacherDetails() async {
    try {
      // Replace with your actual endpoint URL
      final response = await http.get(
        Uri.parse(
            'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_teacher_detail.php?id=$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      //
      if (response.statusCode == 200) {
        final teacherDetails =
            TeacherDetails.fromJson(jsonDecode(response.body));
        setState(() {
          id = teacherDetails.id;
          nom = teacherDetails.nom;
          prenom = teacherDetails.prenom;
        });
        return teacherDetails;
      } else {
        throw Exception('Failed to load teacher details');
      }
    } catch (e) {
      print('Error fetching teacher details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tunisia Learning', style: TextStyle(color: Colors.white)),
        actions: [
          FutureBuilder<int>(
            future: _notificationCountFuture,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              int count = snapshot.data ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'Profile Paramètre':
                  Navigator.pushNamed(
                    context,
                    MyProfileScreen.routeName,
                    arguments: {'id': id},
                  );
                  break;
                case 'Logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Profile Paramètre',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Profile Paramètre'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      //drawer: SideMenu(id: id, nom: nom, prenom: prenom),
      body: FutureBuilder<TeacherDetails?>(
        future: _teacherDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            return buildContent(snapshot.data!);
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget buildContent(TeacherDetails teacherDetails) {
    return Scaffold(
      //the appbar part

      //drawer: SideMenu(id: id, nom: nom, prenom: prenom),
      body: Column(
        children: [
          // We will divide the screen into two parts
          // Fixed height for first half
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4.5,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
            // padding: EdgeInsets.all(20.0),
            color: kPrimaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nom d'utilisateur :",
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontSize: 12.0,
                                  ),
                        ),
                        //exemple of a name of user methode get
                        Text('${teacherDetails.nom} ${teacherDetails.prenom}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                )),

                        Text(
                          'Nom d\'établissement :',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontSize: 12.0,
                                  ),
                        ),
                        Text('${teacherDetails.etablissement}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                )),

                        Text(
                          'Année scolaire en cours:',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontSize: 12.0,
                                  ),
                        ),

                        Text('${teacherDetails.anneeScolaireEnCours}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                )),
                      ],
                    ),
                    SizedBox(width: 25.0),
                    CircleAvatar(
                      radius: SizerUtil.deviceType == DeviceType.tablet
                          ? 12.w
                          : 13.w,
                      backgroundColor: Color.fromARGB(255, 204, 238, 230),
                      backgroundImage:
                          AssetImage('assets/images/teacher_profil.png'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //the up part done
          //the down part
          //the expanded part
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Color(0xFFF4F6F7),
                borderRadius: kTopBorderRadius,
              ),
              child: SingleChildScrollView(
                //for padding
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        HomeCard(
                          onPress: () {
                            Navigator.pushNamed(
                                context, TeacherMessagingPage.routeName,
                                arguments: {
                                  'iduser': int.parse(teacherDetails.id
                                      .toString()), // Ensure it's an integer
                                  'idetablissement': int.parse(teacherDetails
                                      .idEtablissement
                                      .toString()), // Ensure it's an integer
                                });
                          },
                          icon: 'assets/icons/ask.svg',
                          title: 'Messagerie',
                        ),
                        HomeCard(
                          onPress: () {
                            Navigator.pushNamed(
                                context, MyProfileScreen.routeName,
                                arguments: {
                                  'iduser': int.parse(teacherDetails.id),
                                });
                          },
                          icon: 'assets/icons/resume.svg',
                          title: 'Profil',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        HomeCard(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              AbscenceScreen.routeName,
                              arguments: {
                                'iduser': int.parse(teacherDetails.id),
                                'idetablissement':
                                    int.parse(teacherDetails.idEtablissement),
                              },
                            );
                          },
                          icon: 'assets/icons/holiday.svg',
                          title: 'Demande D\'absences',
                        ),
                        HomeCard(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              RatrapageScreen.routeName,
                              arguments: {
                                'iduser': int.parse(teacherDetails.id),
                                'idetablissement':
                                    int.parse(teacherDetails.idEtablissement),
                              },
                            );
                          },
                          icon: 'assets/icons/timetable.svg',
                          title: 'Demande De Rattrapage',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        /*HomeCard(
                          onPress: () {
                            Navigator.pushNamed(
                                context, MyProfileScreen.routeName,
                                arguments: {
                                  'iduser': int.parse(teacherDetails.id),
                                });
                          },
                          icon: 'assets/icons/resume.svg',
                          title: 'Profil',
                        ),*/
                        HomeCard(
                          onPress: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              LoginScreen.routeName,
                              (Route<dynamic> route) => false,
                            );
                          },
                          icon: 'assets/icons/logout.svg',
                          title: 'Logout',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard(
      {Key? key,
      required this.onPress,
      required this.icon,
      required this.title})
      : super(key: key);
  final VoidCallback onPress;
  final String icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(top: 1.h),
        width: 40.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(20.0 / 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: SizerUtil.deviceType == DeviceType.tablet ? 30.sp : 40.sp,
              width: SizerUtil.deviceType == DeviceType.tablet ? 30.sp : 40.sp,
              color: Color(0xFFF4F6F7),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class YearSelectionWidget extends StatefulWidget {
  @override
  _YearSelectionWidgetState createState() => _YearSelectionWidgetState();
}

class _YearSelectionWidgetState extends State<YearSelectionWidget> {
  // Initialize the selected year
  String _selectedYear = '2023-2024';

  // List of years to select from
  final List<String> _years = [
    '2023-2024',
    '2022-2023',
    '2021-2022',
    '2020-2021',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFFF4F6F7),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedYear,
          onChanged: (String? newValue) {
            setState(() {
              _selectedYear = newValue!;
            });
          },
          items: _years.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12.0,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w200,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TeacherDetails {
  final String id;
  final String nom;
  final String prenom;
  final String dateNaissance;
  final String lieuNaissance;
  final String adresse;
  final String telephone;
  final String sexe;
  final String email;
  final String idEtablissement;
  final String etablissement;
  final String anneeScolaireEnCours;

  TeacherDetails({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.adresse,
    required this.telephone,
    required this.sexe,
    required this.email,
    required this.idEtablissement,
    required this.etablissement,
    required this.anneeScolaireEnCours,
  });

  factory TeacherDetails.fromJson(Map<String, dynamic> json) {
    return TeacherDetails(
      id: json['data']['id'] ?? '',
      nom: json['data']['nom'] ?? '',
      prenom: json['data']['prenom'] ?? '',
      dateNaissance: json['data']['date_naissance'] ?? '',
      lieuNaissance: json['data']['lieu_naissance'] ?? '',
      adresse: json['data']['adresse'] ?? '',
      telephone: json['data']['telephone'] ?? '',
      sexe: json['data']['sexe'] ?? '',
      email: json['data']['email'] ?? '',
      idEtablissement: json['data']['idetablissement'] ?? '',
      etablissement: json['data']['etablissement'] ?? '',
      anneeScolaireEnCours: json['data']['annee_scolaire_en_cours'] ?? '',
    );
  }
}
