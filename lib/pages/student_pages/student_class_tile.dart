import 'package:blue_print/pages/student_pages/student_attendance_page.dart';
import 'package:blue_print/pages/teacher_pages/teacher_attendance_page.dart';
import 'package:blue_print/pages/teacher_pages/teacher_class_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentClassTile extends StatelessWidget {
  final String className;
  final String classCode;
  final String studentCode;
  final String studentName;

  //final lectureType;

  const StudentClassTile({
    super.key,
    required this.classCode,
    required this.className,
    required this.studentCode, required this.studentName,

    //required this.lectureType,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: primaryColor
              // image: const DecorationImage(
              //     image: AssetImage("lib/assets/subject_background.jpg"),
              //     fit: BoxFit.cover),
              ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentAttendancePage(
                              className: className,
                              classCode: classCode,
                              studentCode: studentCode
                              ,studentName: studentCode,
                          )));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    child: Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 70,
                            color: blueColor,
                            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          ),
                          Expanded(
                            child:
                                //Picture of the subject
                                Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(classCode,
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                          // fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: Colors.white),
                                    )),

                                //Subject Name

                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(className.toUpperCase(),
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Colors.white),
                                      )),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
