import 'dart:convert';
import 'dart:io';

import 'package:blue_print/pages/coordinator_pages/add_student_page.dart';
import 'package:blue_print/pages/coordinator_pages/attendance_date_tile.dart';
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

    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
          foregroundColor: primaryColor,
          backgroundColor: primaryColor,
          shadowColor: primaryColor,
          leading: IconButton(icon: Icon(Icons.menu, color: Colors.white,),onPressed: null,),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
              child:Text(
                widget.className.toUpperCase(),
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white)),
              ),),
              Text(
                widget.classCode,
                style: GoogleFonts.openSans(
                  fontSize: 15,
                    textStyle: TextStyle(color: Colors.white54)),
              ),
              Text(
                "Teachers",
                style: GoogleFonts.openSans(
                    fontSize: 12,
                    textStyle: TextStyle(color: Colors.white70)),
              ),


              SingleChildScrollView(child:
              SizedBox(
                  height: 30,
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
                                        Teacher["teacherCode"]
                                        ,


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
              ),)
            ],
          ),
        actions:<Widget>[
          IconButton(onPressed: () => _showAddTeacherDialogBox(context),
              icon: Icon(Icons.person_add, color: Colors.white,)),
          IconButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddStudentPage(classCode:  widget.classCode, className: widget.className,)
                )
            );
          },
              icon: Icon(Icons.school, color: Colors.white,))
        ] ,
      )
      ,
      body: Column(
        children: [

          SizedBox(
            height: 700,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("classes")
                            .doc(widget.classCode)
                            .collection("attendance")
                            .orderBy("date")
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
                                  final date =
                                  snapshot.data!.docs[index];
                                  return AttendanceDateTile(
                                    date:date["date"],
                                    presentStudents: date["totalPresentStudents"],
                                    totalstudents: "6",


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
        ],
      )
    );
  }
}
