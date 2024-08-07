import 'package:flutter/cupertino.dart';
import 'package:flutter_first_project/screens/my_profile/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/screens/my_profile/my_profile.dart';
import 'package:flutter_first_project/screens/home_screen/home_screen.dart';
import 'package:sizer/sizer.dart';

//stf
class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => SideMenuState();
}

class SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: Color.fromARGB(255, 124, 183, 142),
        child: Column(
          children: [
            //
            // Close Button
            Align(
            
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // Closes the drawer
                },
              ),
            ),
            //
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: null,
                    /*Text(
                    '${widget.prenom} ${widget.nom}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),*/
                    currentAccountPicture: CircleAvatar(
                      radius: SizerUtil.deviceType == DeviceType.tablet
                          ? 12.w
                          : 13.w,
                      backgroundColor: Color.fromARGB(255, 204, 238, 230),
                      backgroundImage: AssetImage('assets/images/reading.png'),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(251, 197, 238, 184),
                    ),
                    accountEmail: null,
                  ),

                  /*  UserAccountsDrawerHeader(
                    accountName: Text(
                      'mariem ben hassen',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    accountEmail: Text(
                      'Teacher',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal),
                    ),
                   
                    //this if you want to add an image as a cover
                    /* decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/image1.jpeg'),
                        fit: BoxFit.fill,
                      ),
                    ),*/

                    decoration: BoxDecoration(
                      color: Colors.white12,
                    ),
                  ),
*/
                  //home part
                  ListTile(
                    leading: Icon(
                      Icons.home_filled,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 25,
                    ),
                    title: Text(
                      "Tableau de bord",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.normal),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    ),
                  ),
                  //modifier profile
                  //
                  ListTile(
                    leading: Icon(
                      Icons.home_filled,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 25,
                    ),
                    title: Text(
                      "Cours et exercices ",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.normal),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    ),
                  ),
                  //
                  //
                  ListTile(
                    leading: Icon(
                      Icons.message_rounded,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 25,
                    ),
                    title: Text(
                      "Messagerie interne",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.normal),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    ),
                  ),
                  //divider2
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text(
                      'Notification',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.normal),
                    ),
                    onTap: () => null,
                    trailing: ClipOval(
                      child: Container(
                        color: Colors.red,
                        width: 20,
                        height: 20,
                        child: Center(
                          child: Text(
                            '8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
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
  }
}
