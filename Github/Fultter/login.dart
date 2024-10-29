// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _MyWidgetState();
}

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
bool _passwordVisible = false;

void loginAPI(BuildContext context, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.2.34:3000/login'), // Your Node.js backend URL
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Handle success
      final user = jsonDecode(response.body);
      switch (user["role"]) {
        case 0:
          // Navigator.pushNamed(context, '/user',arguments: user["id"]);
          _emailController.clear();
          _passwordController.clear();

          Navigator.pushReplacementNamed(
            context,
            '/user',
            arguments: user["id"],
          );
          break;
        default:
      }
    } else {
      // Handle failure
      showErrorDialog(context, response.body);
    }
  } catch (e) {
    showErrorDialog(context, e);
  }
}

// Success Alert
void showSuccessDialog(BuildContext context, textAlert) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.rightSlide,
    title: 'Success',
    desc: '$textAlert.',
    btnOkOnPress: () {},
  ).show();
}

// Error Alert
void showErrorDialog(BuildContext context, textAlert) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.rightSlide,
    title: 'Error',
    desc: '$textAlert.',
    btnOkOnPress: () {},
  ).show();
}

// Question Alert (with Yes/No buttons)
void showQuestionDialog(BuildContext context, textAlert) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.question,
    animType: AnimType.rightSlide,
    title: 'Are you sure?',
    desc: '$textAlert',
    btnCancelOnPress: () {
      print("Cancel Pressed");
    },
    btnOkOnPress: () {
      print("OK Pressed");
    },
  ).show();
}

class _MyWidgetState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                          fontFamily: 'LilitaOne',
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      style: TextStyle(
                        fontFamily: 'LilitaOne',
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        labelText: "Email",
                        labelStyle: const TextStyle(
                            fontFamily: 'LilitaOne',
                            color: Colors.black54,
                            fontSize: 20),
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(
                            fontFamily: 'LilitaOne', color: Colors.black54),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                       style: TextStyle(
                        fontFamily: 'LilitaOne',
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        labelText: "Password",
                        labelStyle: const TextStyle(
                            fontFamily: 'LilitaOne',
                            color: Colors.black54,
                            fontSize: 20),
                        hintText: 'Enter your Password',
                        hintStyle: const TextStyle(
                            fontFamily: 'LilitaOne', color: Colors.black54),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3), width: 2.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 13, bottom: 13,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => BorderSide(
                                        color: Colors
                                            .white.withOpacity(0.3), // Set your desired border color here
                                        width: 2.0, // Set the width of the border
                                      ),
                                    ),
                                  ),
                                ),
                                child: Checkbox(
                                  checkColor: Colors.black54,
                                  activeColor: Colors.white,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  value: _passwordVisible,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _passwordVisible = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const Text(
                                "Show password",
                                style: TextStyle(
                                    fontFamily: 'LilitaOne', color: Colors.white,fontSize: 20,),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'LilitaOne',
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        final email = _emailController.text.toString();
                        final password = _passwordController.text.toString();
                        loginAPI(context, email, password);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.green[200]),
                        minimumSize: WidgetStateProperty.all(
                            Size(MediaQuery.of(context).size.width, 45)),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.black38,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
