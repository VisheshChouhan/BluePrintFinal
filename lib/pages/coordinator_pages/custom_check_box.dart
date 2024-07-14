import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCheckBox extends StatefulWidget {
  final Map<String, String> student;
  final bool isPresent;
  final String classCode;
  final String date;

  final ValueChanged<bool> onChanged;
  const CustomCheckBox(
      {super.key,
      required this.student,
      required this.isPresent,
      required this.onChanged,
      required this.classCode,
      required this.date});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    return Container(
      padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
      margin: EdgeInsets.fromLTRB(10, 3, 10, 3),
      
      decoration: BoxDecoration(color: blueColor,borderRadius: BorderRadius.circular(10)),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          newCheckBox(onChanged: widget.onChanged, isPresent: widget.isPresent),
          SizedBox(width: 20,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.student["studentName"]!,
                style: GoogleFonts.openSans(fontSize: 15, color: Colors.white),
              ),
              Text(
                widget.student["studentCode"]!,
                style: GoogleFonts.openSans(fontSize: 12, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}

class newCheckBox extends StatelessWidget {
  const newCheckBox({
    super.key,
    required this.onChanged,
    required this.isPresent,
  });

  final ValueChanged<bool> onChanged;
  final bool isPresent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isPresent),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isPresent ? Colors.green : Colors.red,
          // border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child:
            isPresent ? Icon(Icons.check, size: 18, color: Colors.white) : null,
      ),
    );
  }
}
