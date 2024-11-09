import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pie_chart/pie_chart.dart';

class staffPage extends StatefulWidget {
  const staffPage({super.key});

  @override
  State<staffPage> createState() => _MyWidgetState();
}

final TextEditingController _roomIDController = TextEditingController();

class _MyWidgetState extends State<staffPage> {
  @override
  late Map<String, dynamic>? args;
  late Map<String, double>? dataMap;

  final List<Color> colorList = [
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];
  List? rooms;
  List? history;
  List? dashboard;
  double availableCount = 9999;
  double unavailableCount = 9999;
  double pendingCount = 9999;
  double reservedCount = 9999;

  Future<void> getRoomAPI() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.2.36:3000/rooms'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          rooms = jsonDecode(response.body);
        });
      } else {
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> putRoomAPI(roomID) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.2.36:3000/staff/add'),
        body: jsonEncode({
          'roomID': roomID,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          showSuccessDialog(context, response.body.toString());
          getRoomAPI();
        });
      } else {
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> patchRoomAPI(slotID, room_time_status) async {
    try {
      final response = await http.patch(
        Uri.parse('http://192.168.2.36:3000/staff/edit'),
        body: jsonEncode({
          'slotID': slotID,
          'room_time_status': room_time_status,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          showSuccessDialog(context, response.body.toString());
          getRoomAPI();
        });
      } else {
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> deleteRoomAPI(constext, slotID) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.2.36:3000/staff/delete'),
        body: jsonEncode({
          'slotID': slotID,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          showSuccessDialog(context, response.body.toString());
          getRoomAPI();
        });
      } else {
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> getDashboardAPI() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.2.36:3000/dashboard'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          dashboard = jsonDecode(response.body);
          Map<String, double> statusCounts = {};
          for (var item in dashboard!) {
            String? status = item["status"];
            String? countStr = item["Count"];
            if (status != null) {
              statusCounts[status] =
                  double.tryParse(countStr.toString()) ?? 0.0;
            }
          }
          availableCount = statusCounts["Available"] ?? 0.0;
          unavailableCount = statusCounts["Unavailable"] ?? 0.0;
          pendingCount = statusCounts["Pending"] ?? 0.0;
          reservedCount = statusCounts["Reserved"] ?? 0.0;
        });
      } else {
        showErrorDialog(context,
            "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      showErrorDialog(context, "Exception: ${e.toString()}");
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

  Future<void> getHistoryAPI() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.2.36:3000/staff/history'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          history = jsonDecode(response.body);
        });
      } else {
        showErrorDialog(context,
            "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      showErrorDialog(context, "Exception: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRoomAPI();
      getHistoryAPI();
      getDashboardAPI();
    });
  }

  Widget build(BuildContext context) {
    DateTime now = DateTime.now(); // Get the current date and time
    Color firstColor = Color.fromARGB(255, 254, 190, 191);
    Color secondColor = Color.fromARGB(255, 87, 150, 225);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.1,
          backgroundColor: secondColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.account_circle_rounded,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(color: Colors.grey, blurRadius: 12.0)
                      ],
                      size: 40,
                    ),
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.question,
                        animType: AnimType.rightSlide,
                        title: 'Log out?',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                      ).show();
                    },
                  ),
                  Text(
                    "Staff",
                    style:
                        TextStyle(fontFamily: 'LilitaOne', color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: secondColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: const [
              Tab(
                icon: Icon(Icons.home),
                // text: 'Home',
              ),
              Tab(
                icon: Icon(Icons.timelapse),
                // text: 'History',
              ),
              Tab(
                icon: Icon(Icons.pie_chart),
                // text: 'History',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ====================================================HOME========================================================
            RefreshIndicator(
              backgroundColor: secondColor,
              color: firstColor,
              onRefresh: getRoomAPI,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        color: firstColor,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Rooms",
                              style: TextStyle(
                                  fontFamily: 'LilitaOne',
                                  color: Colors.white,
                                  fontSize: 30),
                            ),
                            FilledButton(
                                style: ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize:
                                      MaterialStateProperty.all(Size(40, 20)),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero),
                                  backgroundColor:
                                      WidgetStateProperty.all(secondColor),
                                  elevation: WidgetStateProperty.all(3),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                ),
                                onPressed: () => rentForm(),
                                child: Icon(
                                  Icons.add,
                                  color: firstColor,
                                )),
                          ],
                        )),
                    SafeArea(
                      child: Container(
                        height: (rooms != null && rooms!.length > 3)
                            ? null
                            : MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: firstColor,
                        child: rooms != null
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: rooms?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'ID: ${rooms?[index]["slotID"]}',
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        'Building: ${rooms?[index]["building"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        'Room ID: ${rooms?[index]["roomID"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        'Booking time: ${rooms?[index]["borrow_time"]} to ${rooms?[index]["return_time"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Row(
                                                      children: [
                                                        Text("Room status: ",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'LilitaOne',
                                                            )),
                                                        Text(
                                                            (rooms?[index][
                                                                        "room_time_status"] ==
                                                                    "1")
                                                                ? "Available"
                                                                : "Unavailable",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                color: ((rooms?[index]
                                                                            [
                                                                            "room_time_status"] ==
                                                                        "1")
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red))),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Image.asset(
                                                  "assets/${rooms?[index]['image']}",
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.black,
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                          color: Colors.grey,
                                                          blurRadius: 12.0)
                                                    ],
                                                    size: 20,
                                                  ),
                                                  onPressed: () => editForm(
                                                      context,
                                                      rooms?[index]["slotID"],
                                                      (rooms?[index][
                                                          "room_time_status"])),
                                                ),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.black,
                                                      shadows: <Shadow>[
                                                        Shadow(
                                                            color: Colors.grey,
                                                            blurRadius: 12.0)
                                                      ],
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      AwesomeDialog(
                                                        context: context,
                                                        dialogType:
                                                            DialogType.question,
                                                        animType:
                                                            AnimType.rightSlide,
                                                        title: 'Are you sure?',
                                                        btnCancelOnPress: () {},
                                                        btnOkOnPress: () => deleteRoomAPI(context, rooms?[index]["slotID"]),
                                                      ).show();
                                                    })
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Text(
                                "No rooms available",
                                style: TextStyle(
                                  fontFamily: 'LilitaOne',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //history
            RefreshIndicator(
              backgroundColor: secondColor,
              color: firstColor,
              onRefresh: getHistoryAPI,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        color: firstColor,
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          "History",
                          style: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.white,
                              fontSize: 30),
                        )),
                    SafeArea(
                      child: Container(
                        height: (history != null && history!.length > 3)
                            ? null
                            : MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: firstColor,
                        child: history != null
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: history?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'ID: ${history?[index]["id"]}',
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        'Building: ${history?[index]["building"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        'Room ID: ${history?[index]["roomID"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        'Student ID: ${history?[index]["studentID"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Row(
                                                      children: [
                                                        Text('Reason: ',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'LilitaOne',
                                                            )),
                                                        FilledButton(
                                                          onPressed: () =>
                                                              showSuccessDialog(
                                                                  context,
                                                                  history?[
                                                                          index]
                                                                      [
                                                                      "request_reason"]),
                                                          child: Text(
                                                            "Show",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          style: ButtonStyle(
                                                            tapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            minimumSize:
                                                                MaterialStateProperty
                                                                    .all(Size(
                                                                        40,
                                                                        20)),
                                                            padding:
                                                                MaterialStateProperty
                                                                    .all(EdgeInsets
                                                                        .zero),
                                                            backgroundColor:
                                                                WidgetStateProperty
                                                                    .all(
                                                                        secondColor),
                                                            elevation:
                                                                WidgetStateProperty
                                                                    .all(3),
                                                            shape: WidgetStateProperty
                                                                .all<
                                                                    RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                        'Booking time: ${history?[index]["borrow_time"]} to ${history?[index]["return_time"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        "Request date: ${history?[index]["request_date"]}",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Row(
                                                      children: [
                                                        Text("Request status: ",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'LilitaOne',
                                                            )),
                                                        Text(
                                                            (history?[index][
                                                                        "request_status"] ==
                                                                    "1")
                                                                ? "Approved"
                                                                : "Disapproved",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                color: ((history?[index]
                                                                            [
                                                                            "request_status"] ==
                                                                        "1")
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red))),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text("Borrow status: ",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'LilitaOne',
                                                            )),
                                                        Text(
                                                          (history?[index][
                                                                      "borrow_status"] ==
                                                                  '0')
                                                              ? "-"
                                                              : (history?[index]
                                                                          [
                                                                          "borrow_status"] ==
                                                                      "1")
                                                                  ? "Used"
                                                                  : "Returned",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'LilitaOne',
                                                            color: (history?[
                                                                            index]
                                                                        [
                                                                        "borrow_status"] ==
                                                                    "0")
                                                                ? Colors.black
                                                                : (history?[index]
                                                                            [
                                                                            "borrow_status"] ==
                                                                        "1")
                                                                    ? Colors.red
                                                                    : const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        76,
                                                                        163,
                                                                        175),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Image.asset(
                                                  "assets/${history?[index]['image']}",
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Text(
                                "No rooms available",
                                style: TextStyle(
                                  fontFamily: 'LilitaOne',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================================================================================================
            //dashboard
            RefreshIndicator(
              onRefresh: getDashboardAPI,
              child: SafeArea(
                  child: Container(
                      padding: EdgeInsets.all(15),
                      color: firstColor,
                      child: ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Dashboard",
                                style: TextStyle(
                                    fontFamily: 'LilitaOne',
                                    color: Colors.white,
                                    fontSize: 25),
                              )),
                          Container(
                            margin: EdgeInsets.all(30),
                            child: PieChart(
                              dataMap: dataMap = {
                                "Available": availableCount,
                                "Reserve": reservedCount,
                                "Pending": pendingCount,
                                "Unavailable": unavailableCount,
                              },
                              animationDuration: Duration(milliseconds: 800),
                              chartLegendSpacing: 32.0,
                              chartRadius:
                                  MediaQuery.of(context).size.width / 3.2,
                              colorList: colorList,
                              chartType: ChartType.ring,
                              ringStrokeWidth: 32,
                              legendOptions: LegendOptions(
                                showLegendsInRow: false,
                                legendPosition: LegendPosition.right,
                                showLegends: true,
                                legendShape: BoxShape.circle,
                              ),
                              chartValuesOptions: ChartValuesOptions(
                                showChartValueBackground: true,
                                showChartValues: true,
                                showChartValuesInPercentage: true,
                                showChartValuesOutside: false,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Available",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "${availableCount}",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Unavailable",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "${unavailableCount}",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.yellow,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Pending",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "${pendingCount}",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Reserved",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "${reservedCount}",
                                      style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))),
            ),
          ],
        ),
      ),
    );
  }

  Future rentForm() => showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Room ID: ",
                      style: TextStyle(
                        fontFamily: 'LilitaOne',
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _roomIDController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontFamily: 'LilitaOne'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 254, 190, 191),
                          labelText: "Room ID",
                          labelStyle: const TextStyle(
                            fontFamily: 'LilitaOne',
                            color: Colors.black45,
                            fontSize: 20,
                          ),
                          hintText: 'Enter room ID',
                          hintStyle: const TextStyle(
                              fontFamily: 'LilitaOne', color: Colors.black54),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.red[300]),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _roomIDController.clear();
                      },
                      child: Text("Cancel",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'LilitaOne',
                          )),
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.green[300]),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        String roomID = _roomIDController.text;
                        if (roomID != "") {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.question,
                            animType: AnimType.rightSlide,
                            title: 'Are you sure?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {
                              putRoomAPI(roomID);
                            },
                          ).show();
                        }
                      },
                      child: Text("Confirm",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'LilitaOne',
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  Future<void> editForm(BuildContext context, int slotID, status) => showDialog(
        context: context,
        builder: (context) {
          int? selectedValue = int.tryParse(status);
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Slot ID: $slotID",
                        style: TextStyle(
                          fontFamily: 'LilitaOne',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status: ",
                            style: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 254, 190, 191),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: selectedValue,
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      "Select Value",
                                      style: TextStyle(
                                        fontFamily: 'LilitaOne',
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text("0",
                                            style: TextStyle(
                                                fontFamily: 'LilitaOne')),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text("1",
                                            style: TextStyle(
                                                fontFamily: 'LilitaOne')),
                                      ),
                                    ),
                                  ],
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedValue =
                                          newValue; // Update the selected value
                                    });
                                  },
                                  style: TextStyle(
                                      fontFamily: 'LilitaOne',
                                      color: Colors.black),
                                  iconEnabledColor: Colors.black,
                                  dropdownColor:
                                      Color.fromARGB(255, 254, 190, 191),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red[300]),
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _roomIDController.clear();
                            },
                            child: Text("Cancel",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'LilitaOne',
                                )),
                          ),
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green[300]),
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (slotID != "") {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.question,
                                  animType: AnimType.rightSlide,
                                  title: 'Are you sure?',
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () {
                                    patchRoomAPI(slotID, selectedValue);
                                  },
                                ).show();
                              }
                            },
                            child: Text("Confirm",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'LilitaOne',
                                )),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
}
