import 'dart:convert';
import 'dart:io';

import 'package:blue_print/pages/coordinator_pages/add_student_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassPage extends StatefulWidget {
  final String classCode;
  final String className;
  const ClassPage(
      {super.key, required this.classCode, required this.className});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {

  TextEditingController _teacherUniqueCodeController = new TextEditingController();
  String? filePath;


  FirebaseFirestore db = FirebaseFirestore.instance;
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // Method to Create New class
  void addNewTeacher() {
    checkExistingTeacher();
  }

  Future checkExistingTeacher() async {
    var a = await db
        .collection('teacher')
        .doc(_teacherUniqueCodeController.text.toString())
        .get();

    if (!a.exists) {
      print("Teacher doesn't Exists");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Teacher doesn't exist with given Code.\nUse a different Code."),
      ));
      return a;
    }

    if (a.exists) {
      print('Teacher exists');

      String teacherCode = _teacherUniqueCodeController.text.toString().trim();
      // String className = _classNameController.text.toString();

      if (_teacherUniqueCodeController.text.isNotEmpty) {
        db
            .collection("classes")
            .doc(widget.classCode)
            .collection("teachers")
            .doc(teacherCode)
            .set({"teacherCode": teacherCode});
        db
            .collection("coordinator")
            .doc(currentUserId)
            .collection("classes")
            .doc(widget.classCode)
            .collection("teachers")
            .doc(teacherCode)
            .set({"teacherCode": teacherCode});

        db
            .collection("teacher")
            .doc(teacherCode)
            .collection("classes")
            .doc(widget.classCode)
            .set({"courseCode": widget.classCode, "courseName": widget.className});




        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Teacher Assigned Succesfully"),
        ));

        _teacherUniqueCodeController.clear();



      }
      return null;
    }
  }



  void _showAddTeacherDialogBox(BuildContext context) {
    // Form key for validation
    final _formKey = GlobalKey<FormState>();
    // Controllers for text fields

    // Show dialog with the form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Teacher'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the dialog box smaller
              children: <Widget>[
                TextFormField(
                  controller: _teacherUniqueCodeController,
                  decoration: InputDecoration(labelText: 'Enter Teacher Unique Code'),
                ),

              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate() && _teacherUniqueCodeController.text.isNotEmpty) {
                  // If the form is valid, proceed to handle the data
                  addNewTeacher();

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
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Text(
                widget.className,
                style: GoogleFonts.abel(
                  textStyle: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.classCode,
                style: GoogleFonts.abel(
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(onPressed: () => _showAddTeacherDialogBox(context), child: Text("Add Teacher")),
            SizedBox(height: 20,),
            Text("Assigned Teacher:"),
            SizedBox(
                height: 100,
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
                              .doc(widget.classCode)
                              .collection("teachers")
                              .orderBy("teacherCode")
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
                                    final Teacher =
                                    snapshot.data!.docs[index];
                                    return Text(
                                      Teacher["teacherCode"],

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
                    ]
                )
            ),
            
            ElevatedButton(onPressed:() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddStudentPage(classCode:  widget.classCode, className: widget.className,)
                  )
              );
            }, child: Text("Add students"))
          ],
        ),
      ),
    );
  }
}
