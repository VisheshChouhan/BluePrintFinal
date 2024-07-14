import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../teacher_pages/custom_map.dart';
import 'custom_check_box.dart';

class CoordinatorAttendancePage extends StatefulWidget {
  final String classCode;
  final String className;
  final String date;
  final String presentStudents;
  final String totalstudents;
  const CoordinatorAttendancePage(
      {super.key,
      required this.classCode,
      required this.className,
      required this.date,
      required this.presentStudents,
      required this.totalstudents});

  @override
  State<CoordinatorAttendancePage> createState() =>
      _CoordinatorAttendancePageState();
}

class _CoordinatorAttendancePageState extends State<CoordinatorAttendancePage> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);

  // Set<dynamic> selectedStudentCodes = {};
  // Set<CustomMap> finallyPresentStudentMap = {};
  // int totalStudents = 0;
  // FirebaseFirestore db = FirebaseFirestore.instance;
  // TextEditingController attendanceCode = new TextEditingController();
  //
  // @override
  // void initState() {
  //   // implement initState
  //   // selectedStudentCodes = widget.initialPresentStudents;
  //   super.initState();
  // }
  //
  // void onCheckboxChanged(
  //     String studentCode, String studentName, bool isChecked) {
  //   setState(() {
  //     if (isChecked) {
  //       selectedStudentCodes.add(studentCode);
  //       CustomMap temp = new CustomMap({'studentCode': studentCode, 'studentName': studentName});
  //       finallyPresentStudentMap
  //           .add(temp);
  //     } else {
  //       selectedStudentCodes.remove(studentCode);
  //       CustomMap temp = new CustomMap({'studentCode': studentCode, 'studentName': studentName});
  //       finallyPresentStudentMap
  //           .remove(temp);
  //     }
  //   });
  // }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, String>>> getAllStudents() {
    return _firestore
        .collection('classes')
        .doc(widget.classCode)
        .collection("students")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'studentCode': doc['studentCode'].toString(),
                'studentName': doc['studentName'].toString(),
              })
          .toList();
    });
  }

  Stream<List<Map<String, String>>> getPresentStudents() {
    return _firestore
        .collection('classes')
        .doc(widget.classCode)
        .collection("attendance")
        .doc(widget.date)
        .collection("presentStudents")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'studentCode': doc['studentCode'].toString(),
                'studentName': doc['studentName'].toString(),
              })
          .toList();
    });
  }

  Future<void> _confirmAttendanceChange(
      BuildContext context, Map<String, String> student, bool isPresent) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isPresent ? 'Remove Student' : 'Add Student'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to ${isPresent ? 'remove' : 'add'} ${student['studentName']} (${student['studentCode']}) from the attendance list?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() async {
                  Navigator.of(context).pop();
                  if (isPresent) {
                    // Remove student from present list
                    _firestore
                        .collection('classes')
                        .doc(widget.classCode)
                        .collection("attendance")
                        .doc(widget.date)
                        .collection("presentStudents")
                        .doc(student["studentCode"].toString())
                        .delete();
                    DocumentReference docRef = _firestore
                        .collection("classes")
                        .doc(widget.classCode)
                        .collection("attendance")
                        .doc(widget.date);

                    try {
                      DocumentSnapshot doc = await docRef.get();
                      if (doc.exists) {
                        int currentValue =
                            int.parse(doc['totalPresentStudents']);
                        int newValue = currentValue - 1;

                        await docRef.update(
                            {'totalPresentStudents': newValue.toString()});

                        print('Updated value: $newValue');
                      } else {
                        print('Document does not exist!');
                      }
                    } catch (e) {
                      print('Error updating document: $e');
                    }
                  } else {
                    // Add student to present list
                    // Add student to present list
                    _firestore
                        .collection('classes')
                        .doc(widget.classCode)
                        .collection("attendance")
                        .doc(widget.date)
                        .collection("presentStudents")
                        .doc(student["studentCode"].toString())
                        .set({
                      'studentCode': student['studentCode'].toString(),
                      'studentName': student['studentName'].toString(),
                    });

                    DocumentReference docRef = _firestore
                        .collection("classes")
                        .doc(widget.classCode)
                        .collection("attendance")
                        .doc(widget.date);

                    try {
                      DocumentSnapshot doc = await docRef.get();
                      if (doc.exists) {
                        int currentValue =
                            int.parse(doc['totalPresentStudents']);
                        int newValue = currentValue + 1;

                        await docRef.update(
                            {'totalPresentStudents': newValue.toString()});

                        print('Updated value: $newValue');
                      } else {
                        print('Document does not exist!');
                      }
                    } catch (e) {
                      print('Error updating document: $e');
                    }
                  }
                });
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
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            SingleChildScrollView(scrollDirection: Axis.horizontal,child:Expanded(

                child:Text(
              "Attendace of ${widget.className.toUpperCase()}",
              style: GoogleFonts.openSans(fontSize: 20, color: Colors.white),
            )),),
            Text(
              widget.date,
              style: GoogleFonts.openSans(fontSize: 15, color: Colors.white),
            )
          ],
        ),
      ),
      body: SizedBox(height: 700,child: Expanded(child: StreamBuilder<List<Map<String, String>>>(
        stream: getAllStudents(),
        builder: (context, allStudentsSnapshot) {
          if (allStudentsSnapshot.hasError) {
            return Center(child: Text('Error: ${allStudentsSnapshot.error}'));
          }

          if (!allStudentsSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final allStudents = allStudentsSnapshot.data!;

          return StreamBuilder<List<Map<String, String>>>(
            stream: getPresentStudents(),
            builder: (context, presentStudentsSnapshot) {
              if (presentStudentsSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${presentStudentsSnapshot.error}'));
              }

              if (!presentStudentsSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final presentStudents = presentStudentsSnapshot.data!;

              return ListView.builder(
                itemCount: allStudents.length,
                itemBuilder: (context, index) {
                  final student = allStudents[index];
                  final isPresent = presentStudents.any((presentStudent) =>
                      presentStudent['studentCode'] == student['studentCode']);

                  return CustomCheckBox(
                      onChanged: (bool? value) {
                        _confirmAttendanceChange(context, student, isPresent);
                      },
                      student: student,
                      isPresent: isPresent,
                      classCode: widget.classCode,
                      date: widget.date,
                    )
                  ;
                },
              );
            },
          );
        },
      ),
    )));
  }
}
