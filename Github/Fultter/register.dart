import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _MyWidgetState();
}

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

class _MyWidgetState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();

  void registerAPI(BuildContext context, email,  name, studentID , password) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.2.36:3000/register'), // Your Node.js backend URL
        body: jsonEncode({
          'email': email,
          'name': name,
          'password': password,
          'studentID': studentID
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Handle success
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Register success!',
          desc: '${response.body}',
          btnOkOnPress: () {
            Navigator.pushReplacementNamed(
              context,
              '/login',
            );
          },
        ).show();
      } else {
        // Handle failure
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      // showErrorDialog(context, e);
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 40,
        ),
        backgroundColor: const Color.fromARGB(255, 87, 150, 225),
      ),
      body: SafeArea(
        child: Container(
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
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.white,
                              fontSize: 45,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
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
                          labelStyle: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.black54,
                              fontSize: 20),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                              fontFamily: 'LilitaOne', color: Colors.black54),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: TextStyle(
                                fontFamily: 'LilitaOne',
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                labelText: "Username",
                                labelStyle: TextStyle(
                                  fontFamily: 'LilitaOne',
                                  color: Colors.black54,
                                  fontSize: 20,
                                ),
                                hintText: 'Enter your username',
                                hintStyle: TextStyle(
                                  fontFamily: 'LilitaOne',
                                  color: Colors.black54,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20), 
                          Expanded(
                            child: TextField(
                              controller: _studentIDController,
                              style: TextStyle(
                                fontFamily: 'LilitaOne',
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                labelText: "Student ID",
                                labelStyle: TextStyle(
                                  fontFamily: 'LilitaOne',
                                  color: Colors.black54,
                                  fontSize: 20,
                                ),
                                hintText: 'Enter your Student ID',
                                hintStyle: TextStyle(
                                  fontFamily: 'LilitaOne',
                                  color: Colors.black54,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        style: TextStyle(
                          fontFamily: 'LilitaOne',
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                          labelText: "Password",
                          labelStyle: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.black54,
                              fontSize: 20),
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(
                              fontFamily: 'LilitaOne', color: Colors.black54),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _repasswordController,
                        style: TextStyle(
                          fontFamily: 'LilitaOne',
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                          labelText: "Re-enter password",
                          labelStyle: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.black54,
                              fontSize: 20),
                          hintText: 'Re-enter your password',
                          hintStyle: TextStyle(
                              fontFamily: 'LilitaOne', color: Colors.black54),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FilledButton(
                        onPressed: () {
                          final email = _emailController.text.toString();
                          final name = _nameController.text.toString();
                          final password = _passwordController.text.toString();
                          final repassword =_repasswordController.text.toString();
                          final studentID = _studentIDController.text.toString();

                          if (password == repassword && password != "" && repassword != "") {
                            // Proceed with registration
                            registerAPI(context, email, name, studentID, password);
                          } 
                          if (password != repassword && password != "" && repassword != ""){
                            // Show error dialog
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              title: 'Error',
                              desc: 'Passwords do not match!',
                              btnOkOnPress: () {},
                            ).show();
                          }
                          if (email == "" ||
                              password == "" ||
                              repassword == "") {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              title: 'Error',
                              desc: 'Please fill all data!',
                              btnOkOnPress: () {},
                            ).show();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.green[200]),
                          minimumSize: WidgetStateProperty.all(
                              Size(MediaQuery.of(context).size.width, 45)),
                          elevation: WidgetStateProperty.all(0),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Register",
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
      ),
    );
  }
}
