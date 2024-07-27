import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:blue_print/assets/my_color_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'package:csv/csv.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStudentPage extends StatefulWidget {
  final String classCode;
  final String className;
  const AddStudentPage(
      {Key? key, required this.classCode, required this.className})
      : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  List<List<dynamic>> _data = [];
  List<List<dynamic>> _UnableToAddStudentList = [];
  String? filePath;
  TextEditingController _studentCodeController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> checkDocument(String studentUID) async {
    try {
      // Fetch the document from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classCode) // Replace with your document ID
          .collection("students")
          .doc(studentUID)
          .get();

      if (doc.exists) {
        // Document exists, handle the data
        print('Document Data: ${doc.data()}');
      } else {
        // Document does not exist, perform the operation
        print('Document does not exist. Performing operation...');
        // Example operation: Add a new document
        // This increment the number of total classes by one
        DocumentReference docRef =
        db.collection('classes').doc(widget.classCode);
        db.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(docRef);

          if (!snapshot.exists) {
            throw Exception("Document does not exist!");
          }

          int currentValue = snapshot["totalStudents"];
          int newValue = currentValue + 1;
          transaction.update(docRef, {'totalStudents': newValue});
        }).then((_) {
          print("Transaction successfully committed!");
        }).catchError((error) {
          print("Transaction failed: $error");
        });

        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(content: Text("Data Successfully stored")));
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }


  Future<bool> addStudent(String StudentUID) async {
    StudentUID = StudentUID.toUpperCase().toString().trim();
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("students").doc(StudentUID);
    bool result = true;

    await docRef.get().then((DocumentSnapshot doc) async {
      if (doc.exists) {

        await checkDocument(StudentUID);
        final data = doc.data() as Map<String, dynamic>;
        db
            .collection("classes")
            .doc(widget.classCode)
            .collection("students")
            .doc(StudentUID)
            .set({
          "studentCode": StudentUID,
          "studentName": data["studentName"],
          "totalDaysPresent": 0
        });

        db
            .collection("students")
            .doc(StudentUID)
            .collection("classes")
            .doc(widget.classCode)
            .set({
          "classCode": widget.classCode,
          "className": widget.className,
          "totalDaysPresent":0
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Student added Succesfully"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("The student $StudentUID doesn't exists."),
        ));
        result = false;
        print("result");
        print(result);
      }
    });
    print("reslut 1");
    print(result);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColorThemeTheme.visheshPrimaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Add Students",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
              )),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _studentCodeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Enter Student Unique Code"),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColorThemeTheme.visheshPrimaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero
                )
              ),
                onPressed: () => addStudent(_studentCodeController.text),
                child: Text("Add Student", style: GoogleFonts.openSans(
                  color: Colors.white
                ),)),
            const Divider(
              color: Colors.black,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    backgroundColor: MyColorThemeTheme.visheshPrimaryColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Expanded(
                        child: AlertDialog(
                          title: Text('File Format Alert',
                              style: GoogleFonts.abel(
                                textStyle: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              )),
                          content: Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(children: [
                                Container(
                                  child: Text("Student UID",
                                      style: GoogleFonts.abel(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Container(
                                  child: Text("Student Name",
                                      style: GoogleFonts.abel(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                  child: Text("....",
                                      style: GoogleFonts.abel(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Container(
                                  child: Text("....",
                                      style: GoogleFonts.abel(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                  child: Text("....",
                                      style: GoogleFonts.abel(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Container(
                                  child: Text("....",
                                      style: GoogleFonts.abel(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                )
                              ]),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              //textColor: Colors.black,
                              onPressed: () {
                                _pickFile();
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  /*_pickFile();*/
                },
                child: Text("Select File",
                    style: GoogleFonts.openSans(
                      textStyle:
                          const TextStyle(fontSize: 30, color: Colors.white),
                    )),
              ),
            ),

            Text("Student that can't be enrolled."),
            //Unable to Enroll Student List
            Expanded(
              child: ListView.builder(
                itemCount: _UnableToAddStudentList.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.zero, // Set the border radius to zero
                    ),
                    margin: const EdgeInsets.all(3),
                    color: index == 0 ? Colors.blue : Colors.white,
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 200,
                            color: index == 0 ? Colors.blue : Colors.white,
                            child: Flexible(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                strutStyle: const StrutStyle(fontSize: 12.0),
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: index == 0 ? 18 : 15,
                                        fontWeight: index == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: index == 0
                                            ? Colors.white
                                            : Colors.black),
                                    text: _UnableToAddStudentList[index][0]
                                        .toString()),
                              ),
                            ),
                            /*Text(_data[index][0].toString(),textAlign: TextAlign.center,
                            style: TextStyle(fontSize: index == 0 ? 18 : 15, fontWeight: index == 0 ? FontWeight.bold :FontWeight.normal,color: index == 0 ? Colors.red : Colors.black),),*/
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const VerticalDivider(
                            color: MyColorThemeTheme.visheshPrimaryColor,
                            thickness: 2,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            color: index == 0 ? Colors.blue : Colors.white,
                            child: Text(
                              _UnableToAddStudentList[index][1].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: index == 0 ? 18 : 15,
                                  fontWeight: index == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      index == 0 ? Colors.white : Colors.black),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text("Student successfully enrolled."),
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.zero, // Set the border radius to zero
                    ),
                    margin: const EdgeInsets.all(3),
                    color: index == 0 ? Colors.blue : Colors.white,
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 200,
                            color: index == 0 ? Colors.blue : Colors.white,
                            child: Flexible(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                strutStyle: const StrutStyle(fontSize: 12.0),
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: index == 0 ? 18 : 15,
                                        fontWeight: index == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: index == 0
                                            ? Colors.white
                                            : Colors.black),
                                    text: _data[index][0].toString()),
                              ),
                            ),
                            /*Text(_data[index][0].toString(),textAlign: TextAlign.center,
                            style: TextStyle(fontSize: index == 0 ? 18 : 15, fontWeight: index == 0 ? FontWeight.bold :FontWeight.normal,color: index == 0 ? Colors.red : Colors.black),),*/
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          VerticalDivider(
                            color: MyColorThemeTheme.visheshPrimaryColor,
                            thickness: 2,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Container(
                            color: index == 0 ? Colors.blue : Colors.white,
                            child: Text(
                              _data[index][1].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: index == 0 ? 18 : 15,
                                  fontWeight: index == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      index == 0 ? Colors.white : Colors.black),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  if (_data.isNotEmpty) {
                    List<List<dynamic>> tempUnableToEnrollList = [
                      ["Student UID", "Student Name"],
                    ];

                    for (var element in _data
                        .skip(1)) // for skip first value bcs its contain name
                    {
                      bool result = await addStudent(element[0]);
                      print(result);
                      if (result == false) {
                        tempUnableToEnrollList.add(element);
                        setState(() {
                          _UnableToAddStudentList = tempUnableToEnrollList;
                        });
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please select a file."),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  foregroundColor: MyColorThemeTheme.blueColor,
                  backgroundColor: MyColorThemeTheme.blueColor
                ),
                child: Text(
                  "Enroll Students",
                  style: GoogleFonts.abel(
                      textStyle: TextStyle(fontSize: 20), color: Colors.white),
                ),
              ),
            ),
          ],
        ));
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(result.files.first.name);
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    print(fields);

    setState(() {
      _data = fields;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }
}
