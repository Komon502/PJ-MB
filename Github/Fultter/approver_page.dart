import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pie_chart/pie_chart.dart';

class approverPage extends StatefulWidget {
  const approverPage({super.key});

  @override
  State<approverPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<approverPage> {
  @override
  List? rooms;
  List? request;
  List? history;
  List? dashboard;
  late int? userID;
  late String? username;
  late Map<String, dynamic>? args;
  late Map<String, double>? dataMap;
  final List<Color> colorList = [
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];
  double availableCount = 9999;
  double unavailableCount = 9999;
  double pendingCount = 9999;
  double reservedCount = 9999;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();

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

  Future<void> getRequestAPI() async {
    if (userID == null) {
      showErrorDialog(context, "User ID not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.2.36:3000/approver/request'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          request = jsonDecode(response.body);
        });
      } else {
        showErrorDialog(context,
            "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      showErrorDialog(context, "Exception: ${e.toString()}");
    }
  }

  Future<void> getHistoryAPI() async {
    userID = args?["id"] as int?;
    if (userID == null) {
      showErrorDialog(context, "User ID not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.2.36:3000/approver/history?userID=$userID'),
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

  void approveRequest(requestID, requestStatus) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.rightSlide,
      title: 'Are you sure?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        patchRequestStautus(requestID, requestStatus);
        print("$requestID, $requestStatus");
      },
    ).show();
  }

  Future<void> patchRequestStautus(requestID, requestStatus) async {
    userID = args?["id"] as int?;
    // showSuccessDialog(context, '${userID}, ${roomID}');
    try {
      final response = await http.patch(
        Uri.parse('http://192.168.2.36:3000/approver/changeRequestStatus'),
        body: jsonEncode({
          'requestID': requestID,
          'requestStatus': requestStatus,
          'approverID': userID
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          showSuccessDialog(context, response.body.toString());
          getRequestAPI();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRoomAPI();
      getRequestAPI();
      getHistoryAPI();
      getDashboardAPI();
    });
  }

  Widget build(BuildContext context) {
    args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userID = args?["id"] as int?;
    username = args?["username"] as String;
    DateTime now = DateTime.now(); // Get the current date and time
    Color firstColor = Color.fromARGB(255, 254, 190, 191);
    Color secondColor = Color.fromARGB(255, 87, 150, 225);

    return DefaultTabController(
      length: 4,
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
                    "$username",
                    style:
                        TextStyle(fontFamily: 'LilitaOne', color: Colors.white),
                  )
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
                icon: Icon(Icons.book),
                // text: 'My request',
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

            // Home
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
                        child: const Text(
                          "Room",
                          style: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.white,
                              fontSize: 30),
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
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
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
                                                      'Building: ${rooms?[index]["building"]}',
                                                      style: const TextStyle(
                                                        fontFamily: 'LilitaOne',
                                                      ),
                                                    ),
                                                    Text(
                                                      'Room ID: ${rooms?[index]["roomID"]}',
                                                      style: const TextStyle(
                                                        fontFamily: 'LilitaOne',
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text("Status: ",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'LilitaOne',
                                                            )),
                                                        Text(
                                                          rooms?[index][
                                                                      "room_time_status"] ==
                                                                  "1"
                                                              ? "Available"
                                                              : "Unavailable",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'LilitaOne',
                                                            color: rooms?[index]
                                                                        [
                                                                        "room_time_status"] ==
                                                                    "1"
                                                                ? Colors.green
                                                                : Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "Booking time: ${rooms?[index]["borrow_time"]} to ${rooms?[index]["return_time"]}",
                                                      style: const TextStyle(
                                                        fontFamily: 'LilitaOne',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Image.asset(
                                                  "assets/${rooms?[index]['image']}",
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                )
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

            // Request
            RefreshIndicator(
              backgroundColor: secondColor,
              color: firstColor,
              onRefresh: getRequestAPI,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        color: firstColor,
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          "Request",
                          style: TextStyle(
                              fontFamily: 'LilitaOne',
                              color: Colors.white,
                              fontSize: 30),
                        )),
                    SafeArea(
                      child: Container(
                        height: (request != null && request!.length > 3)
                            ? null
                            : MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: firstColor,
                        child: request != null
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: request?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
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
                                                      'ID: ${request?[index]["id"]}',
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        'Building: ${request?[index]["building"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        'Room ID: ${request?[index]["roomID"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        'Username: ${request?[index]["username"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Text(
                                                        'Student ID: ${request?[index]["studentID"]}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'LilitaOne',
                                                        )),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Reason: ',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'LilitaOne',
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () =>
                                                              showSuccessDialog(
                                                                  context,
                                                                  request?[
                                                                          index]
                                                                      [
                                                                      "request_reason"]),
                                                          child: Text(
                                                            "Show",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'LilitaOne'),
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
                                                        "Booking time: ${request?[index]["borrow_time"]} to ${request?[index]["return_time"]}",
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
                                                        Text("Pending",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                color: Colors
                                                                        .yellow[
                                                                    700])),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Image.asset(
                                                  "assets/${request?[index]["image"]}",
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                FilledButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .green)),
                                                    onPressed: () =>
                                                        approveRequest(
                                                            request?[index]
                                                                ["id"],
                                                            "1"),
                                                    child: Text("Approve",
                                                        style:
                                                            TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                color: Colors
                                                                    .white))),
                                                FilledButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .red)),
                                                    onPressed: () =>
                                                        approveRequest(
                                                            request?[index]
                                                                ["id"],
                                                            "0"),
                                                    child: Text("Disapprove",
                                                        style:
                                                            TextStyle(
                                                                fontFamily:
                                                                    'LilitaOne',
                                                                color: Colors
                                                                    .white)))
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
                              animationDuration:
                                  Duration(milliseconds: 800),
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
}
