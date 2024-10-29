import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddRoomPage extends StatefulWidget {
  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  File? _imageFile;
  int _currentIndex = 0;

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BrowseRoomPage()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ListPage()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AccessTimePage()));
        break;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFBEBE),
      appBar: AppBar(
        title: Text('Add Room'),
        backgroundColor: Color(0xFF0077FF),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.file(
                          _imageFile!,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(Icons.add_a_photo, color: Colors.grey[700]),
                      ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _buildingController,
                decoration: InputDecoration(
                  labelText: 'Building',
                  hintText: 'Building Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: 'Room',
                  hintText: 'Room Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String building = _buildingController.text;
                  String room = _roomController.text;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Room $room in $building added!'),
                    ),
                  );
                },
                child: Text('Add Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0077FF),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToPage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Access Time',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Color(0xFFFFBEBE),
      ),
    );
  }
}
