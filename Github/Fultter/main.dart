import 'package:flutter/material.dart';
import 'package:myapp/Project/login.dart';
import 'package:myapp/Project/register.dart';
import 'package:myapp/Project/user_page.dart';

void main() {
  
  runApp(Material(
    child: MaterialApp(
      // home: const LoginPage(), // Replace with the main widget from column.dart
      debugShowCheckedModeBanner: false,
       routes: {
        '/login' : (context) => const LoginPage(),
        '/register' : (context) => const RegisterPage(),
        '/user' : (context) => const userPage(),
        
      //   '/two' : (context) => const SecondRoute(),
      },
      initialRoute: '/login'
    ),
  ));
}
