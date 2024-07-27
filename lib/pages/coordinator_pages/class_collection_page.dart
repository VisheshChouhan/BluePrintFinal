
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../assets/my_color_theme.dart';
import '../../models/class_tile.dart';

class ClassCollectionPage extends StatefulWidget {
  const ClassCollectionPage({super.key});

  @override
  State<ClassCollectionPage> createState() => _ClassCollectionPageState();
}

class _ClassCollectionPageState extends State<ClassCollectionPage> {
  final TextEditingController _classCodeController = new TextEditingController();
  final TextEditingController _classNameController = new TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // Method to Create New class
  void createNewClass(String newClassCode) {
    checkExistingClass(newClassCode);
  }

  Future checkExistingClass(String newClassCode) async {
    var a = await db
        .collection('coordinator')
        .doc(newClassCode)
        .get();

    if (a.exists) {
      print('Exists');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Course Already exist with given Code.\nUse a different Code."),
      ));
      return a;
    }

    if (!a.exists) {
      print('Not exists');

      String classCode = newClassCode;
      String className = _classNameController.text.toString().trim().toUpperCase();

      if (_classCodeController.text.isNotEmpty &&
          _classNameController.text.isNotEmpty) {
        db
            .collection("coordinator")
            .doc(currentUserId)
            .collection("classes")
            .doc(classCode)
            .set({"classCode": classCode, "className": className});

        db
            .collection("classes")
            .doc(classCode)
            .set({"courseCode": classCode, "courseName": className});

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Class Created Succesfully"),
        ));

        _classNameController.clear();
        _classCodeController.clear();
      }
      return null;
    }
  }

  void _showCreateClassDialogBox(BuildContext context) {
    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
    // Form key for validation
    final _formKey = GlobalKey<FormState>();
    // Controllers for text

    String? selectedDepartmentCode = 'CO'; // Default country code
    final List<String> subjectCodesList = [
      "CO",
      "PY",
      "IP",
      "ME",
      "CE",
      "EE",
      "EC",
      "EI",
      "CH",
      "BM",
      "MA",
      "MBA"
      // Add more subject codes as needed
    ];



    // Show dialog with the form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          title: Text(
            'Create Class',
            style: GoogleFonts.openSans(fontSize: 24),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the dialog box smaller
              children: <Widget>[

                Row(
                  children: [
                    Container(
                      width: 95, // Adjust the width as needed
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Department \nCode',
                          labelStyle: GoogleFonts.openSans(fontSize: 15, color: Colors.blue),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: MyColorThemeTheme.blueColor,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        value: selectedDepartmentCode,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDepartmentCode = newValue;
                          });
                        },
                        items: subjectCodesList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(width: 5.0),
                    Expanded(
                      child: TextFormField(
                        controller: _classCodeController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Enter Class Code',
                          labelStyle:
                          GoogleFonts.openSans(fontSize: 15, color: Colors.blue),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: MyColorThemeTheme.blueColor,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                  width: 600,
                ),
                TextFormField(
                  controller: _classNameController,
                  decoration: InputDecoration(
                    labelText: 'Enter Class Name',
                    labelStyle:
                        GoogleFonts.openSans(fontSize: 15, color: Colors.blue),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: blueColor,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue), // Set background color
                shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0), // Set border radius to 0 for square shape
                  ),
                ),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.openSans(color: Colors.white),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate() && _classCodeController.text.isNotEmpty && _classNameController.text.isNotEmpty) {
                  // If the form is valid, proceed to handle the data
                  String newClassCode = selectedDepartmentCode.toString().toUpperCase() + _classCodeController.text.toString().toUpperCase();
                  print("new Class Code"+newClassCode);
                  createNewClass(newClassCode);

                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
    return Scaffold(
        extendBodyBehindAppBar: true,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your action here
            _showCreateClassDialogBox(context);
          },
          backgroundColor: blueColor,
          child: const Icon(
            Icons.add,
            size: 40.0,
            color: Colors.white, // Adjust icon size as needed
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
            child: Stack(children: [
          Container(
            height: 300,
            color: primaryColor,
          ),
          Column(children: [
            const SizedBox(
              height: 100,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: [
                  // SizedBox(
                  //   height: 40,
                  // ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                      height: 660,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("coordinator")
                                    .doc(currentUserId)
                                    .collection("classes")
                                    .orderBy("classCode")
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          final Class =
                                              snapshot.data!.docs[index];
                                          return ClassTile(
                                            courseName: Class["className"],
                                            courseCode: Class["classCode"],
                                          );
                                        });
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error:${snapshot.error}'),
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                          ])),
                ],
              ),
            )
          ])
        ])));
  }
}
