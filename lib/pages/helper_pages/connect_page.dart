import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// import 'package:attendy_app/attendance_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'attendance_screen.dart';

class ConnectPage extends StatefulWidget {
  final bool showOptionalButtons;
  final int? batchId;

  const ConnectPage(
      {super.key, this.showOptionalButtons = true, this.batchId = 1});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
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

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    espOutputController.text = "esp output";
    // requestPermission();

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        _pairedDevices = bondedDevices;
      });
    });
  }

  // Future<void> requestPermission() async {
  //   // You can request multiple permissions at once.
  //   Map<Permission, PermissionStatus> statuses = await [
  //   Permission.location,
  //       Permission.bluetooth,
  //   ].request();
  //   print(statuses[Permission.location]);
  //
  // }

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
  Future<void> _enrollFinger(
      {required String userSerial,
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

  void _onDataReceived(Uint8List data) {
    // Accumulate the current chunk of data
    String currentData = utf8.decode(data);
    _completeData += currentData;

    print("current data: "+ currentData);
    // print("print1 " + _completeData);
    // List<String> usernames = _processReceivedData(_completeData);
    // print("print2 " + usernames.toString());
    
    if(currentData.startsWith("ep: ")){
      // setState(() {
      //   espOutput = currentData.toString();
      // });
    }
    if(currentData.startsWith("tp: ")){

      print("template: " + currentData.toString());

    }

    List<String> currentDataList = currentData.split("\n");



    for (String data in currentDataList){
      print("currentDataListData: "+ data);
      // Runs whenever new template comes in
      if(data.startsWith("tb")){
        templateNumber = 0;
        templateData = "";
      }
      //Runs when the template is completely transferred to the flutter application
      if(data.startsWith("te")){
        if(templateData.length == 1024){
           db.collection('students').doc(userSerialController.text.toUpperCase().replaceAll(' ', '')).set({
            'template': templateData,
          });
        }
        else{
          print("The template is incomplete");
        }

        templateData = '';
        templateNumber = 0;



      }
      if (data.startsWith("tp:")){
        String tempTemplateData = data.substring(4,6);
        templateData = "$templateData$tempTemplateData";
        templateNumber+=1;
        print("template DATa $templateData");
        print("template length " + templateData.length.toString());
        print("data substring"+tempTemplateData+"|");
        setState(() {
          espOutput = templateData;
        });

      }
      if(templateNumber==512){
        print("Template is "+ templateData);
      }
      // else{
      //   print("Error fetcing template");
      // }

    }





    


    // Check if the transmission is complete (indicated by '%')
    if (_completeData.contains('%')) {
      // If complete, process the data
      List<String> usernames = _processReceivedData(_completeData);
      // Navigate to the next screen with the list of usernames
      _navigateToNextScreen(usernames);

      // Reset the accumulated data
      _completeData = '';
    }
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

  void _navigateToNextScreen(List<String> usernames) {
    // Here, you should replace `NextScreen` with the actual class of your next screen.
    // Also, make sure the next screen has a constructor that accepts a List<String>.
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => (usernames: usernames),
    //   ),
    // );

    _showDialog("Data", usernames.toString());
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AttendanceScreen(initialPresentUsernames: usernames, batchId: widget.batchId,),
    //   ),
    // );
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
    } catch (exception) {
      setState(() {
        _isConnecting = false;
        _showConnectingDialog = false; // Dismiss dialog
      });
      _showDialog('Error', exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Fingerprint Scanner'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _pairedDevices.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:
                          Text(_pairedDevices[index].name ?? 'Unknown Device'),
                      trailing: ElevatedButton(
                        child: Text('Connect'),
                        onPressed: _isConnected || _isConnecting
                            ? null
                            : () => _connectDevice(_pairedDevices[index]),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    espOutput = "changed";
                  });
                },
                child: Text("Change"),
              ),

              ElevatedButton(
                child: Text('Enroll Finger'),
                onPressed: _isConnected
                    ? () => _showEnrollFingerDialog(context)
                    : null,
              ),
              SizedBox(height: 10),
              Text(
                espOutput,
              ),
              SizedBox(height: 10),

              ElevatedButton(
                child: Text('Fetch Attendance Data'),
                onPressed: _isConnected
                    ? () async {
                        _connection?.output
                            .add(Uint8List.fromList(utf8.encode("s")));
                        await _connection?.output.allSent;
                      }
                    : null,
              ),
              // Conditionally show Button 2 and Button 3 based on showOptionalButtonsif (widget.showOptionalButtons) ...[
              ElevatedButton(
                child: Text('Reset Attendance Store'),
                onPressed: _isConnected
                    ? () {
                        _connection?.output
                            .add(Uint8List.fromList(utf8.encode("r")));
                      }
                    : null,
              ),
            ],
          ),
          // Show a modal dialog with a progress indicator while connecting
          if (_showConnectingDialog) ...[
            const Opacity(
              opacity: 0.6,
              child: ModalBarrier(
                dismissible: false,
                color: Colors.grey,
              ),
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}
