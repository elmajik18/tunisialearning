import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/home_screen/child_detail_screen.dart';
import 'package:flutter_first_project/screens/login_screen/login_screen.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ParentHomeScreen extends StatefulWidget {
  static const String routeName = 'ParentHomeScreen';

  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  late String id;
  late String nomprenom;
  List<dynamic> children = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['id'] == null || args['nomprenom'] == null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid arguments')),
        );
      });
      return;
    }

    id = args['id'];
    nomprenom = args['nomprenom'];
    _fetchChildrenData();
  }

  Future<void> _fetchChildrenData() async {
    final url =
        'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/get_children.php';
    final response = await http.post(Uri.parse(url), body: {'id': id});

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        Set<String> namesSet = Set();
        List<dynamic> fetchedChildren =
            List.from(responseData['data']).where((child) {
          String childName = child['nom'] + ' ' + child['prenom'];
          if (namesSet.contains(childName)) {
            return false;
          } else {
            namesSet.add(childName);
            return true;
          }
        }).toList();

        if (fetchedChildren.length == 1) {
          _navigateToChildDetailScreen(context, fetchedChildren.first);
        } else {
          setState(() {
            children = fetchedChildren;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF345FB4),
        title: Text(
          'Tunisia Learning',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
                color: Colors.white,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, size: 30),
            onPressed: () {
              // Handle bell icon press
            },
          ),
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
              offset: Offset(0, 50), // Adjust the offset for vertical alignment
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
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20.0),
            color: Color(0xFF345FB4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nom d'utilisateur :",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 12.0,
                          ),
                    ),
                    Text(nomprenom,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 12.0,
                              color: Colors.white,
                            )),
                    Text(
                      "Nom d'établissement :",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 12.0,
                          ),
                    ),
                    Text('School',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 12.0,
                              color: Colors.white,
                            )),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        'No children found.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(20.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: children.length == 1 ? 1 : 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 20.0,
                      ),
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        return HomeCard(
                          onPress: () {
                            _navigateToChildDetailScreen(context, child);
                          },
                          title: child['nom'] + ' ' + child['prenom'],
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChildDetailScreen(BuildContext context, dynamic child) {
    Navigator.pushNamed(
      context,
      ChildDetailScreen.routeName,
      arguments: {'child': child, 'parentId': id},
    );
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key? key,
    required this.onPress,
    required this.title,
  }) : super(key: key);

  final VoidCallback onPress;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF345FB4),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10.0),
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
