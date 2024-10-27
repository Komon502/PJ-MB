import 'package:flutter/material.dart';
import 'package:myapp/screen/browse_room.dart';
// import 'package:myapp/Admin/add_room_page.dart';
// import 'package:myapp/Admin/edit_room_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Room Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: BrowseRoom(),
    );
  }
}