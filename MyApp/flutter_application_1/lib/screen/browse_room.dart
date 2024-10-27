import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: BrowseRoom(),
    );
  }
}

class BrowseRoom extends StatefulWidget {
  @override
  _BrowseRoomState createState() => _BrowseRoomState();
}

class _BrowseRoomState extends State<BrowseRoom> {
  bool isRoomPending = false;

  void showBookingDialog(BuildContext context, String room, String building) {
    TextEditingController idController = TextEditingController();
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFBEBE),
          title: Text('Room Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Building: $building\nRoom: $room'),
              TextField(
                controller: idController,
                decoration: InputDecoration(hintText: 'Your ID'),
              ),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(hintText: 'Reason'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFFF37171))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isRoomPending = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('Confirm', style: TextStyle(color: Color(0xFF85EE91))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Rooms'),
        backgroundColor: Color(0xFF0077FF),
      ),
      body: Container(
        color: Color(0xFFFFBEBE),
        child: ListView(
          children: <Widget>[
            RoomCard(
              room: '204',
              building: 'C2',
              imagePath: 'img/img1.png',
              isPending: isRoomPending,
              onRent: () {
                if (!isRoomPending) {
                  showBookingDialog(context, '204', 'C2');
                }
              },
            ),
            RoomCard(
              room: '312',
              building: 'C2',
              imagePath: 'img/img1.png',
              isPending: false,
              onRent: () {
                showBookingDialog(context, '312', 'C2');
              },
            ),
            RoomCard(
              room: '401',
              building: 'C2',
              imagePath: 'img/img1.png',
              isPending: false,
              onRent: () {
                showBookingDialog(context, '401', 'C2');
              },
            ),
            RoomCard(
              room: '503',
              building: 'C3',
              imagePath: 'img/img1.png',
              isPending: false,
              onRent: () {
                showBookingDialog(context, '101', 'C3');
              },
            ),
            RoomCard(
              room: '604',
              building: 'C3',
              imagePath: 'img/img1.png',
              isPending: false,
              onRent: () {
                showBookingDialog(context, '102', 'C3');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.history), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String room;
  final String building;
  final String imagePath;
  final bool isPending;
  final VoidCallback onRent;

  RoomCard({
    required this.room,
    required this.building,
    required this.imagePath,
    required this.isPending,
    required this.onRent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: Container(
          width: 70,
          height: 70,
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
        title: Text('Building: $building\nRoom: $room'),
        subtitle: Text('Booking date: 19/10/2024'),
        trailing: isPending
            ? ElevatedButton(
                onPressed: null,
                child: Text('Pending'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF37171),
                ),
              )
            : ElevatedButton(
                onPressed: onRent,
                child: Text('Rent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0077FF),
                ),
              ),
      ),
    );
  }
}
