import 'package:blue_print/pages/teacher_pages/teacher_attendance_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TeacherClassPage extends StatefulWidget {
  final String classCode;
  final String className;
  const TeacherClassPage(
      {super.key, required this.classCode, required this.className});

  @override
  State<TeacherClassPage> createState() => _TeacherClassPageState();
}

class _TeacherClassPageState extends State<TeacherClassPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          Text(widget.className),
          Text(widget.classCode),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TeacherAttendancePage(
                            className: widget.className,
                            classCode: widget.classCode,
                            )));
              },
              child: Text("Take Attendance")
          ),
          ElevatedButton(
              onPressed: null,
              child: Text("View Attendance")
          ),
          ElevatedButton(
              onPressed: null,
              child: Text("All Students")
          ),
        ],
      ),
    );
  }
}
