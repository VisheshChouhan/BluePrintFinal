
import 'package:blue_print/pages/student_pages/student_attendance_page.dart';
import 'package:blue_print/pages/teacher_pages/teacher_attendance_page.dart';
import 'package:blue_print/pages/teacher_pages/teacher_class_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class StudentClassTile extends StatelessWidget {
  final String className;
  final String classCode;
  final String studentUID;


  //final lectureType;

  const StudentClassTile({
    super.key,
    required this.classCode,
    required this.className, required this.studentUID,

    //required this.lectureType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
                image: AssetImage("lib/assets/subject_background.jpg"),
                fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StudentAttendancePage(
                                className: className,
                                classCode: classCode,
                                studentUID: studentUID
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    child: Expanded(
                      child: Row(
                        children: [
                          //Picture of the subject
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(classCode,
                                  style: GoogleFonts.abel(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.white
                                    ),
                                  )),

                              //Subject Name
                              Text(className,
                                  style: GoogleFonts.abel(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.white
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),
        )
    );
  }
}

