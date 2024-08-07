import 'dart:async';
import 'dart:convert';
import 'package:flutter_first_project/constante.dart';
import 'package:flutter_first_project/components/custom_buttons.dart';
import 'package:flutter_first_project/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_first_project/constante.dart';
import 'package:flutter_first_project/screens/home_screen/parent_home_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

// Password visibility: declaration
late bool _passwordVisible;

class LoginScreen extends StatefulWidget {
  static String routeName = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Validate our form now
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields to get input values
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Change current state
  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  //
  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:8080/Tunisia_Learning_backend/TunisiaLearningPhp/login.php'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Response Body: $responseBody');
        final Map<String, dynamic> responseData = json.decode(responseBody);

        if (responseData['success']) {
          print('Login Successful, Role: ${responseData['role']}');
          if (responseData['role'] == 'parent') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              ParentHomeScreen.routeName,
              (route) => false,
              arguments: {
                'id': responseData['data']['id'],
                'nomprenom': responseData['data']['nomprenom'],
              },
            );
          } else if (responseData['role'] == 'teacher') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomeScreen.routeName,
              (route) => false,
              arguments: {
                'id': responseData['data']['id'],
                'nom': responseData['data']['nom'],
                'prenom': responseData['data']['prenom'],
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: ListView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/splash.png',
                    height: 20.h,
                    width: 40.w,
                  ),
                  SizedBox(height: kDefaultPadding / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Tunisia ',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Learning',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  SizedBox(height: kDefaultPadding / 6),
                  Text(
                    'Espace de connexion à la platforme',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                  ),
                  SizedBox(height: kDefaultPadding),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(kDefaultPadding * 3),
                  topRight: Radius.circular(kDefaultPadding * 3),
                ),
                color: kOtherColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: kDefaultPadding),
                          TextFormField(
                            controller: _emailController,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Enter your email or login',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              isDense: true,
                            ),
                            validator: (value) {
                              RegExp regExp = RegExp(emailPattern);
                              if (value == null || value.isEmpty) {
                                return "Please enter some text.";
                              } else if (!regExp.hasMatch(value)) {
                                return "Please enter a valid email address.";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: kDefaultPadding),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _passwordVisible,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.visiblePassword,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Enter your password',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              isDense: true,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                iconSize: kDefaultPadding,
                              ),
                            ),
                            validator: (value) {
                              if (value!.length < 6) {
                                return "Password must be at least 6 characters.";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: kDefaultPadding),
                          DefaultButton(
                            onPress: () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                            title: 'Login',
                            iconData: Icons.arrow_forward_outlined,
                          ),
                          SizedBox(height: kDefaultPadding),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () {
                                // Implement forgot password action
                              },
                              child: Text(
                                'Forgot password?',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
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
            ),
          ],
        ),
      ),
    );
  }
}
