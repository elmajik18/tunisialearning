import 'package:flutter_first_project/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatelessWidget {
  //route name for our screen
  static String routeName = 'SplashScreen';
  @override
  Widget build(BuildContext context) {
    //now the implement of the futur page login
    Future.delayed(
        Duration(seconds: 3),
        () => Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.routeName, (route) => false));

    //scaffold color set to primary color in main in our text theme
    return Scaffold(
      //its a row with a column
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tunisia', style: Theme.of(context).textTheme.headlineLarge),
                Text('Learning', style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
            Image.asset(
              'assets/images/splash.png',
              //25% of height & 50% of width
              height: 25.h,
              width: 50.w,
            ),
          ],
        ),
      ),
    );
  }
}
