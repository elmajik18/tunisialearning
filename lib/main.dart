import 'package:flutter_first_project/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:flutter_first_project/screens/SplashScreen/SplashScreen.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_first_project/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, device) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tunisia Learning',
        theme: CustomTheme().baseTheme,
        //initial route is splash screen
        //mean first screen
        initialRoute: SplashScreen.routeName,
        //define the routes file here in order to access the routes any where all over the app
        routes: routes,
      );
    });
  }
}
