import 'package:blue_print/pages/coordinator_pages/coordinator_attendance_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceDateTile extends StatefulWidget {
  final String classCode;
  final String className;
  final String date;
  final String presentStudents;
  final String totalstudents;
  const AttendanceDateTile(
      {super.key,
      required this.date,
      required this.presentStudents,
      required this.totalstudents,
      required this.classCode,
      required this.className});

  @override
  State<AttendanceDateTile> createState() => _AttendanceDateTileState();
}

class _AttendanceDateTileState extends State<AttendanceDateTile> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CoordinatorAttendancePage(
                        className: widget.className,
                        classCode: widget.classCode,
                        date: widget.date,
                        presentStudents: widget.presentStudents,
                        totalstudents: widget.totalstudents,
                      )));
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: blueColor),
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          height: 40,
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: primaryColor,
                width: 10,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Text(
                      widget.date,
                      style: GoogleFonts.openSans(
                          fontSize: 20,
                          textStyle: TextStyle(color: Colors.white)),
                    ),
                    Text(
                      "${widget.presentStudents}/${widget.totalstudents}",
                      style: GoogleFonts.openSans(
                          fontSize: 15,
                          textStyle: TextStyle(color: Colors.white)),
                    ),
                  ]))
            ],
          ),
        ));
  }
}
