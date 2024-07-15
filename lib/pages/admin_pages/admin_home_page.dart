import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:blue_print/assets/my_color_theme.dart';
import 'package:blue_print/models/MyButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../features/roles/admin/presentation/pages/profile_page.dart';

enum Mode {
  Connect,
  Enroll,
  Delete,
}

class AdminHomePageOld extends StatefulWidget {
  final String adminName;
  final String adminEmail;
  final String adminPhone;
  final String adminDepartment;
  final String adminUniqueId;
  final bool showOptionalButtons;
  final int? batchId;
  const AdminHomePageOld({
    super.key,
    this.showOptionalButtons = true,
    this.batchId = 1,
    required this.adminName,
    required this.adminEmail,
    required this.adminPhone,
    required this.adminDepartment,
    required this.adminUniqueId,
  });

  @override
  State<AdminHomePageOld> createState() => _AdminHomePageOldState();
}

class _AdminHomePageOldState extends State<AdminHomePageOld> with SingleTickerProviderStateMixin {
  Mode _mode = Mode.Connect;
  List<BluetoothDevice> _pairedDevices = [];
  BluetoothConnection? _connection;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _showConnectingDialog = false;
  bool _isBluetoothEnabled = false;
  bool _isLoading = false; // New loading state flag
  String _completeData = '';
  TextEditingController espOutputController = TextEditingController();
  String espOutput = "ESP Output";
  final userSerialController = TextEditingController();
  final userNameController = TextEditingController();
  final fingerNumberController = TextEditingController();

  String templateData = '';
  int templateNumber = 0;

  FirebaseFirestore db = FirebaseFirestore.instance;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    espOutputController.text = "esp output";
    _checkBluetooth();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBluetooth() async {
    setState(() {
      _isLoading = true;
    });
    bool isEnabled = await FlutterBluetoothSerial.instance.isEnabled ?? false;
    setState(() {
      _isBluetoothEnabled = isEnabled;
      _isLoading = false;
    });
    if (isEnabled) {
      _fetchPairedDevices();
    }
  }

  Future<void> _fetchPairedDevices() async {
    setState(() {
      _isLoading = true;
    });
    List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      _pairedDevices = bondedDevices;
      _isLoading = false;
    });
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    setState(() {
      _showConnectingDialog = true;
      _isLoading = true; // Show loader
    });
    try {
      _isConnecting = true;
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address).timeout(Duration(seconds: 10));
      setState(() {
        _connection = connection;
        _isConnected = true;
        _isConnecting = false;
        _showConnectingDialog = false;
        _isLoading = false; // Hide loader
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
        _showConnectingDialog = false;
        _isLoading = false; // Hide loader
      });
      _showDialog('Error', exception.toString());
    }
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
    String currentData = utf8.decode(data);
    _completeData += currentData;

    print("current data: " + currentData);

    if (currentData.startsWith("tp: ")) {
      print("template: " + currentData.toString());
    }

    List<String> currentDataList = currentData.split("\n");

    for (String data in currentDataList) {
      print("currentDataListData: " + data);

      if (data.startsWith("tb")) {
        templateNumber = 0;
        templateData = "";
      }

      if (data.startsWith("te")) {
        if (templateData.length == 1024) {
          db.collection('students').doc(userSerialController.text.toUpperCase().replaceAll(' ', '')).set({
            'template': templateData,
          });
          espOutputController.text = "";
        } else {
          int tempLen = templateData.length;
          print("The template is incomplete");
          print(tempLen);
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
      }

      if (templateNumber == 512) {
        print("Template is " + templateData);
      }

      if (data.startsWith("ep: ")) {
        setState(() {
          espOutput = data.toString();
        });
      }
    }

    if (_completeData.contains('%')) {
      List<String> usernames = _processReceivedData(_completeData);
      _navigateToNextScreen(usernames);
      _completeData = '';
    }
  }

  List<String> _processReceivedData(String rawData) {
    List<String> lines = rawData.split('\n');
    lines = lines.map((line) => line.trim()).where((line) => line.isNotEmpty && line != '%').toList();

    if (lines.isNotEmpty && lines[0] == 'Attendance List:') {
      lines.removeAt(0);
    }

    return lines;
  }

  void _navigateToNextScreen(List<String> usernames) {
    _showDialog("Data", usernames.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.adminName,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: MyColorThemeTheme.whiteColor,
              ),
            ),
            Text(
              'Admin',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: MyColorThemeTheme.whiteColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(adminName: widget.adminName, adminEmail: widget.adminEmail, adminPhone: widget.adminPhone, adminDepartment: widget.adminDepartment,),),);
            },
            icon: const Icon(
              Icons.account_circle_rounded,
              color: MyColorThemeTheme.whiteColor,
              size: 40,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: _mode == Mode.Connect
                    ? MyColorThemeTheme.whiteColor
                    : MyColorThemeTheme.backgroundColor,
                child: Row(
                  children: [
                    Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: Mode.Connect,
                      groupValue: _mode,
                      onChanged: (Mode? val) {
                        setState(() {
                          _mode = val!;
                        });
                      },
                    ),
                    Text(
                      'Connect Device',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(width: 8,),
                    if (_isConnected &&_animation != null)
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _animation.value > 0.3 ? Colors.green : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              if (_mode == Mode.Connect)
                _isLoading
                    ? Container(padding: EdgeInsets.all(16),child: Center(child: CircularProgressIndicator()))
                    : Container(child: _isBluetoothEnabled ? _listOfAvailableDevices() : _bluetoothIsNotOn()),
              SizedBox(height: 16,),
              Container(
                color: _mode == Mode.Enroll
                    ? MyColorThemeTheme.whiteColor
                    : MyColorThemeTheme.backgroundColor,
                child: Row(
                  children: [
                    Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: Mode.Enroll,
                      groupValue: _mode,
                      onChanged: (Mode? val) {
                        setState(() {
                          _mode = val!;
                        });
                      },
                    ),
                    Text(
                      'Enroll Student',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (_mode == Mode.Enroll)
                !_isConnected ? _enrollStudent() : Container(padding: EdgeInsets.all(16), child: Text("Enroll check")),
              SizedBox(height: 16,),
              Container(
                color: _mode == Mode.Delete ? MyColorThemeTheme.whiteColor : MyColorThemeTheme.backgroundColor,
                child: Row(
                  children: [
                    Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: Mode.Delete,
                      groupValue: _mode,
                      onChanged: (Mode? val) {
                        setState(() {
                          _mode = val!;
                        });
                      },
                    ),
                    Text(
                      'Delete Student',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (_mode == Mode.Delete)
                Container(padding: EdgeInsets.all(16), child: Text("Delete check")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bluetoothIsNotOn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (!_isBluetoothEnabled)
            Center(
              child: ElevatedButton(
                onPressed: _checkBluetooth,
                child: Text("Enable Bluetooth and Refresh"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _listOfAvailableDevices() {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.37,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Devices', style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton(
                  onPressed: _checkBluetooth,
                  child: Text("Refresh"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _pairedDevices.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          side: BorderSide(color: Theme.of(context).primaryColor, width: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.bluetooth),
                              SizedBox(width: 8,),
                              Text(_pairedDevices[index].name ?? 'Unknown Device', style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          if (_isConnected) Text('Connected'),
                        ],
                      ),
                      onPressed: _isConnected || _isConnecting
                          ? null
                          : () => _connectDevice(_pairedDevices[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enrollStudent() {
    // final _formKey = GlobalKey<FormState>();
    return Container(
      child: Column(
        children: [
          Column(
            children: <Widget>[
              TextField(
                controller: userSerialController,
                decoration: InputDecoration(labelText: 'Enter user unique ID'),
                // autofocus: true,
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _enrollFinger(userSerial: userSerialController.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _enrollFinger({required String userSerial}) async {
    int id = 0;
    String command = "e-$id-${userSerial.toUpperCase().replaceAll(' ', '')}";
    _connection?.output.add(Uint8List.fromList(utf8.encode(command)));
    await _connection?.output.allSent;
  }
}
