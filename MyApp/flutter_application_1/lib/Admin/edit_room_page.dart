import 'package:flutter/material.dart';

class EditRoomPage extends StatefulWidget {
  @override
  _EditRoomPageState createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  String _status = 'Available';
  DateTime? _bookingDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _bookingDate) {
      setState(() {
        _bookingDate = picked;
      });
    }
  }

  int _selectedIndex = 0;

  // Navigation function
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BrowseRoomPage()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => StatusPage()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HistoryPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Room',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Hi, Boss!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.pink[100],
              child: Center(
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('img/img1.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: _buildingController,
                        decoration: InputDecoration(
                          labelText: 'Building',
                          hintText: 'Building Name',
                        ),
                      ),
                      TextField(
                        controller: _roomController,
                        decoration: InputDecoration(
                          labelText: 'Room',
                          hintText: 'Room Name',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status:',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          DropdownButton<String>(
                            value: _status,
                            items: <String>['Available', 'Disable']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _status = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking date:',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text(
                              _bookingDate == null
                                  ? 'Select Date'
                                  : '${_bookingDate!.day}/${_bookingDate!.month}/${_bookingDate!.year}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          String building = _buildingController.text;
                          String room = _roomController.text;
                          String status = _status;
                          String? date = _bookingDate != null
                              ? '${_bookingDate!.day}/${_bookingDate!.month}/${_bookingDate!.year}'
                              : null;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Room $room in building $building is now $status.'),
                            ),
                          );
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateToPage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
