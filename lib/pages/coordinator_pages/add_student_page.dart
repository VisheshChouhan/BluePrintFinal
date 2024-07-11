import 'dart:collection';
import 'dart:convert';
import 'dart:io';
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
  const AddStudentPage({Key? key, required this.classCode, required this.className}) : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  List<List<dynamic>> _data = [];
  List<List<dynamic>> _UnableToAddStudentList = [];
  String? filePath;
  TextEditingController _studentCodeController = TextEditingController();

  Future<bool> addStudent(String StudentUID) async {
    StudentUID = StudentUID.toUpperCase().toString().trim();
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("students").doc(StudentUID);
    bool result = true;

    await docRef.get().then((DocumentSnapshot doc) {

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        db
            .collection("classes")
            .doc(widget.classCode)
            .collection("students")
            .doc(StudentUID)
            .set({
          "studentCode": StudentUID,
          "studentName": data["studentName"],

        });

        db
            .collection("students")
            .doc(StudentUID)
            .collection("classes")
            .doc(widget.classCode)
            .set({
          "classCode": widget.classCode,
          "className": widget.className,
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
          backgroundColor: Colors.deepPurple,
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.white,
            // Status bar brightness (optional)
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
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
            ElevatedButton(onPressed:() => addStudent(_studentCodeController.text), child: Text("Add Student")),
            Divider(
              color: Colors.black,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
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
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    )),
              ),
            ),

            //Unable to Enroll Student List
            Expanded(
              child: ListView.builder(
                itemCount: _UnableToAddStudentList .length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return Card(
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
                                strutStyle: StrutStyle(fontSize: 12.0),
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: index == 0 ? 18 : 15,
                                        fontWeight: index == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: index == 0
                                            ? Colors.white
                                            : Colors.black),
                                    text: _UnableToAddStudentList[index][0].toString()),
                              ),
                            ),
                            /*Text(_data[index][0].toString(),textAlign: TextAlign.center,
                            style: TextStyle(fontSize: index == 0 ? 18 : 15, fontWeight: index == 0 ? FontWeight.bold :FontWeight.normal,color: index == 0 ? Colors.red : Colors.black),),*/
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const VerticalDivider(
                            color: Colors.deepPurple,
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
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return Card(
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
                                strutStyle: StrutStyle(fontSize: 12.0),
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
                            width: 10,
                          ),
                          const VerticalDivider(
                            color: Colors.deepPurple,
                            thickness: 2,
                          ),
                          const SizedBox(
                            width: 10,
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
                    List<List<dynamic>> tempUnableToEnrollList = [["Student UID", "Student Name"],];

                    for (var element in _data.skip(1)) // for skip first value bcs its contain name
                        {
                          bool result = await addStudent(element[0]);
                          print(result);
                          if (result == false){
                            tempUnableToEnrollList.add(element);
                            setState(() {
                              _UnableToAddStudentList = tempUnableToEnrollList;
                            });
                          }
                    }
                  } else{
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please select a file."),
                    ));


                  }


                }  ,
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),

                ),
                child:  Text("Enroll Students",
                  style: GoogleFonts.abel( textStyle: TextStyle(fontSize: 20),color: Colors.white) ,),
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
