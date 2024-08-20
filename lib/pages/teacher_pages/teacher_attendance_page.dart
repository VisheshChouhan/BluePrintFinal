import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'package:attendy_app/attendance_screen.dart';
import 'package:blue_print/pages/teacher_pages/teacher_present_student_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'attendance_screen.dart';

class TeacherAttendancePage extends StatefulWidget {
  // final bool showOptionalButtons;
  // final int? batchId;
  final String classCode;
  final String className;

  const TeacherAttendancePage(
      {super.key, required this.classCode, required this.className});

  @override
  State<TeacherAttendancePage> createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage> {
  List<BluetoothDevice> _pairedDevices = [];
  BluetoothConnection? _connection;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _showConnectingDialog = false;
  String _completeData = '';
  TextEditingController espOutputController = TextEditingController();
  String espOutput = "ESP Output";
  final userSerialController = TextEditingController();
  final userNameController = TextEditingController();
  final fingerNumberController = TextEditingController();

  String templateData = '';
  int templateNumber = 0;
  Set<dynamic> presentStudents = {};

  // To expand and collapse bluetooth devices
  bool isExpanded = false;
  bool sendingData = false;

  // For progress bar when setting up class
  bool isSettingClass = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    espOutputController.text = "esp output";
    // requestPermission();

    // Request to turn on Bluetooth within an app
    BluetoothEnable.enableBluetooth.then((result) {
      if (result == "true") {
        // Bluetooth has been enabled
      } else if (result == "false") {
        // Bluetooth has not been enabled
      }
    });

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        _pairedDevices = bondedDevices;
      });
    });

    isExpanded = true;

    // _checkBluetooth();
  }

  void refreshBluetoothDevicesList() {
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        _pairedDevices = bondedDevices;
      });
    });
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }

  void _showEnrollFingerDialog(BuildContext context) {
    // Form key for validation
    final _formKey = GlobalKey<FormState>();
    // Controllers for text fields

    // Show dialog with the form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enroll Students'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the dialog box smaller
              children: <Widget>[
                TextFormField(
                  controller: userSerialController,
                  decoration: InputDecoration(labelText: 'Enter User UniqueID'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, proceed to handle the data
                  _enrollFinger(
                    userSerial: userSerialController.text,
                    // userName: userNameController.text
                    //     .trim(), // Remove trailing spaces
                    // fingerNumber: int.parse(fingerNumberController.text),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Method to handle data submission and send the command
  Future<void> _enrollFinger({
    required String userSerial,
    // required String userName,
    // required int fingerNumber
  }) async {
    // Calculate the ID based on the user serial and finger number
    // int id = (userSerial - 1) * 3 +
    //     fingerNumber; // Adjust this calculation as needed based on your ID scheme
    int id = 0;

    // Construct the command
    String command =
        "e-$id-${userSerial.toUpperCase().replaceAll(' ', '')}"; // Construct the command string

    // Send the command
    _connection?.output.add(Uint8List.fromList(utf8.encode(command)));
    await _connection?.output.allSent;

    // You might want to add other logic here, like error handling or response processing
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDataReceived(Uint8List data) async {
    // Accumulate the current chunk of data
    String currentData = utf8.decode(data);
    _completeData += currentData;

    print("current data: " + currentData);
    // print("print1 " + _completeData);
    // List<String> usernames = _processReceivedData(_completeData);
    // print("print2 " + usernames.toString());

    if (currentData.startsWith("ep: ")) {
      // setState(() {
      //   espOutput = currentData.toString();
      // });
    }
    if (currentData.startsWith("tp: ")) {
      print("template: " + currentData.toString());
    }

    List<String> currentDataList = currentData.split("\n");

    for (String data in currentDataList) {
      print("currentDataListData: " + data);
      // Runs whenever new template comes in
      if (data.startsWith("tb")) {
        templateNumber = 0;
        templateData = "";
      }
      //Runs when the template is completely transferred to the flutter application
      if (data.startsWith("te")) {
        if (templateData.length == 1024) {
          db
              .collection('students')
              .doc(userSerialController.text.toUpperCase().replaceAll(' ', ''))
              .set({
            'template': templateData,
          });
        } else {
          print("The template is incomplete");
        }

        templateData = '';
        templateNumber = 0;
      }
      if (data.startsWith("tp:")) {
        String tempTemplateData = data.substring(4, 6);
        templateData = "$templateData$tempTemplateData";
        templateNumber += 1;
        print("template DATa $templateData");
        print("template length " + templateData.length.toString());
        print("data substring" + tempTemplateData + "|");
        setState(() {
          espOutput = templateData;
        });
      }
      if (templateNumber == 512) {
        print("Template is " + templateData);
      }
      // else{
      //   print("Error fetcing template");
      // }

      if (data.startsWith("cd: ")) {
        print("data is " + data);
        String tempClassCode =
            data.toString().substring(4).toUpperCase().trim();
        setState(() {
          sendingData = true;
        });
        String tempCommand = "c-${widget.classCode}";
        _connection?.output.add(Uint8List.fromList(utf8.encode(tempCommand)));
        await _connection?.output.allSent;

        List commandList = await setupClass(tempClassCode);
        sendBulkCommand(commandList);
        setState(() {
          sendingData = false;
        });
      }

      if (data.startsWith("AS:")) {
        presentStudents = {};
      }

      if (data.startsWith("ps: ")) {
        String tempStudent = data.substring(4).trim();
        presentStudents.add(tempStudent);
      }

      if (data.startsWith("AE:")) {
        _navigateToNextScreen(presentStudents);
      }
    }

    // Check if the transmission is complete (indicated by '%')
    // if (_completeData.contains('%')) {
    //   // If complete, process the data
    //   List<String> usernames = _processReceivedData(_completeData);
    //   // Navigate to the next screen with the list of usernames
    //   _navigateToNextScreen(usernames);
    //
    //   // Reset the accumulated data
    //   _completeData = '';
    // }
  }

  List<String> _processReceivedData(String rawData) {
    // Split the data into lines
    List<String> lines = rawData.split('\n');

    // Remove any whitespace and the '%' character
    lines = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line != '%')
        .toList();

    // The first line is "Attendance List:", and usernames follow. We remove the header.
    if (lines.isNotEmpty && lines[0] == 'Attendance List:') {
      lines.removeAt(0);
    }

    // `lines` now contains only the usernames
    return lines;
  }

  //Function to setup the class in the fingerprint Scanner
  Future<List> setupClass(String tempClassCode) async {
    List<dynamic> commandList = [];
    final tempStudentData = [];
    setState(() {
      isSettingClass = true;
    });
    int templateId = 0;

      print("Inside Setup Class else");
      // String tempStudentCode = "FINGER1";
      // String tempStudentTemplate =
      //     "03035C1A1C013501800000000000000000000000000000000000000000000000000000000000000000000000000000000500060079000000C0CCC33030F33CFFFFF3FBFBAABAAAA9AAAAAA66555554555545544401010101010101010101010101010101010101010101010101010101010101010101010101010101010101011A96969E7029A77E63AC265E5534515E6FBA905E30BB52BE623FA6FE6C4366DE52C3D1DE411B665F5F27D01F64B9D05F1EBA147F3BBB683F2F42D2FF35AA529C33A6D3BD30B2697A3134927A389A12383DAED25744AA903444B1D1B428992872271754730AB8403E000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003035A1A0001200181000000000000000000000000000000000000000000000000000000000000000000000000000000030006006D000000C00F0CCC3FCFF33FFFFFEEEAAAAAAAAAA995555555555555040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

      // String command = "t-$templateId-$tempStudentCode-$tempStudentTemplate";
      print(_isConnected);

      //

      // _connection?.output.add(Uint8List.fromList(utf8.encode(command)));
      // await _connection?.output.allSent;
      print("After Inside Setup Class else");
      // print(res);

      // To read students in the class
      await db
          .collection("classes")
          .doc(widget.classCode)
          .collection("students")
          .get()
          .then((event) async {
        for (var doc in event.docs) {
          tempStudentData.add(doc.data()["studentCode"]);
          String tempStudentCode = doc.data()["studentCode"];

          await db.collection("students").doc(tempStudentCode).get().then(
            (event) {
              String tempStudentCode = event.data()?["studentCode"];
              String tempStudentName = event.data()?["studentName"];
              String tempStudentTemplate = event.data()?["template"];
              // print("tempStudentCode "+tempStudentCode);
              // print("tempStudentName "+tempStudentName);
              // print(tempStudentTemplate.length);
              // print("tempStudentTemplate "+tempStudentTemplate);

              String command =
                  "t-$templateId-$tempStudentCode-$tempStudentTemplate"
                      .toString();
              print("command " + command);
              commandList.add(command);
              templateId++;

              // print(" data: ${event.data()}");
            },
            onError: (error) => print("Listen failed: $error"),
          );
        }
        // await Future.delayed(Duration(seconds: 3));
        print("Student in this class: ${tempStudentData.join(", ")}");
      });

      print("Before sending command");

      print("command List");
      print(commandList.toString());

      //To read Students data
      // await db
      //     .collection("students")
      //     .where("studentCode",  whereIn: tempStudentData)
      //     .snapshots()
      //     .listen((event) {
      //   final cities = [];
      //   for (var doc in event.docs) {
      //     cities.add(doc.data()["name"]);
      //   }
      //   print("cities in CA: ${cities.join(", ")}");
      // });

    setState(() {
      isSettingClass = false;
    });

    return commandList;
  }

  Future<void> sendBulkCommand(List<dynamic> commandList) async {
    print("inside send bulk command");
    print(commandList);
    for (String command in commandList) {
      print("command in send BUlk: " + command);
      _connection?.output.add(Uint8List.fromList(utf8.encode(command)));
      await _connection?.output.allSent;
      sleep(Duration(seconds: 3));
    }
  }

  void _navigateToNextScreen(Set<dynamic> usernames) {
    // Here, you should replace `NextScreen` with the actual class of your next screen.
    // Also, make sure the next screen has a constructor that accepts a List<String>.
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => (usernames: usernames),
    //   ),
    // );

    // _showDialog("Data", usernames.toString());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherPresentStudentPage(
          initialPresentStudents: presentStudents,
          classCode: widget.classCode,
          className: widget.className,
        ),
      ),
    );
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    setState(() {
      _showConnectingDialog = true; // Show dialog
    });
    try {
      _isConnecting = true;
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address)
              .timeout(Duration(seconds: 10));
      setState(() {
        _connection = connection;
        _isConnected = true;
        _isConnecting = false;
        _showConnectingDialog = false; // Dismiss dialog
      });

      _connection?.input?.listen(_onDataReceived).onDone(() {
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
      });

      _showDialog('Connected', 'Device connected successfully!');
      isExpanded = !isExpanded;
    } catch (exception) {
      setState(() {
        _isConnecting = false;
        _showConnectingDialog = false; // Dismiss dialog
      });
      // _showDialog('Error', exception.toString());
      _showDialog('Error',
          "Unable to connect to the Bluetooth Device, Please try again...");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);

    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: [
          Center(
            child: isSettingClass ? CircularProgressIndicator(): null,
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                decoration: const BoxDecoration(
                    // color: primaryColor
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "All Bluetooth devices",
                          style: GoogleFonts.openSans(
                              // color: Colors.white,

                              ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            // Refresh action
                            refreshBluetoothDevicesList();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.expand_more),
                          onPressed: () {
                            // Expand action
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              // ElevatedButton(onPressed: (){refreshBluetoothDevicesList();}, child: Text("Refresh")),
              // ElevatedButton(
              //     onPressed: () {
              //       setState(() {
              //         isExpanded = !isExpanded;
              //       });
              //     },
              //     child: Text("Expand")),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: isExpanded ? 600.0 : 0.0,
                child: Expanded(
                  child: ListView.builder(
                    itemCount: _pairedDevices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            _pairedDevices[index].name ?? 'Unknown Device'),
                        trailing: ElevatedButton(
                          onPressed: _isConnected || _isConnecting
                              ? null
                              : () => _connectDevice(_pairedDevices[index]),
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     setState(() {
              //       espOutput = "changed";
              //     });
              //   },
              //   child: Text("Change"),
              // ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      minimumSize: const Size(10, 60),
                      backgroundColor: Colors.blue, // Equal width, fixed height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Optional: slightly rounded
                      ), // Background color of the button
                    ),
                    onPressed: _isConnected && !sendingData
                        ? () async {
                            _connection?.output
                                .add(Uint8List.fromList(utf8.encode("c")));
                            await _connection?.output.allSent;
                          }
                        : null,
                    child: Text(
                      'Setup Device',
                      style: GoogleFonts.openSans(color: Colors.white),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      minimumSize: const Size(10, 60),
                      backgroundColor: Colors.blue, // Equal width, fixed height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Optional: slightly rounded
                      ), // Background color of the button
                    ),
                    onPressed: _isConnected && !sendingData
                        ? () async {
                            _connection?.output
                                .add(Uint8List.fromList(utf8.encode("s")));
                            await _connection?.output.allSent;
                          }
                        : null,
                    child: Text(
                      'Fetch Attendance\n Data',
                      style: GoogleFonts.openSans(color: Colors.white),
                    ),
                  ),
                  // Conditionally show Button 2 and Button 3 based on showOptionalButtonsif (widget.showOptionalButtons) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      minimumSize: const Size(10, 60),
                      backgroundColor: Colors.blue, // Equal width, fixed height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Optional: slightly rounded
                      ), // Background color of the button
                    ),
                    onPressed: _isConnected && !sendingData
                        ? () {
                            _connection?.output
                                .add(Uint8List.fromList(utf8.encode("r")));
                          }
                        : null,
                    child: Text(
                      'Reset Attendance \nData',
                      style: GoogleFonts.openSans(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Text(
              //   espOutput,
              // ),
            ],
          ),
          // Show a modal dialog with a progress indicator while connecting
          // if (_showConnectingDialog) ...[
          //   const Opacity(
          //     opacity: 0.6,
          //     child: ModalBarrier(
          //       dismissible: false,
          //       color: Colors.grey,
          //     ),
          //   ),
          //   const Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // ],
          if (sendingData)
            const SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
        ],
      ),
    ));
  }
}
