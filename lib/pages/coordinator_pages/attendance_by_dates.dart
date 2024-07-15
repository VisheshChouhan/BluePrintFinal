import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_check_box.dart';

class AttendanceByDates extends StatefulWidget {
  final String classCode;
  final String className;
  final String date;
  // final String presentStudents;
  // final String totalstudents;
  const AttendanceByDates({super.key, required this.classCode, required this.className, required this.date});

  @override
  State<AttendanceByDates> createState() => _AttendanceByDatesState();
}

class _AttendanceByDatesState extends State<AttendanceByDates> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);


  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
