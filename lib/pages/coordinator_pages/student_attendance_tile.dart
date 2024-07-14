import 'package:flutter/cupertino.dart';

class StudentAttendanceTile extends StatefulWidget {

  final String classCode;
  final String className;
  final String date;
  final String presentStudents;
  final String totalstudents;
  const StudentAttendanceTile({super.key, required this.classCode, required this.className, required this.date, required this.presentStudents, required this.totalstudents});

  @override
  State<StudentAttendanceTile> createState() => _StudentAttendanceTileState();
}

class _StudentAttendanceTileState extends State<StudentAttendanceTile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
