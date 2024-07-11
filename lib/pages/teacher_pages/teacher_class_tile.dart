
import 'package:blue_print/pages/teacher_pages/teacher_attendance_page.dart';
import 'package:blue_print/pages/teacher_pages/teacher_class_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class TeacherClassTile extends StatelessWidget {
  final String courseName;
  final String courseCode;


  //final lectureType;

  const TeacherClassTile({
    super.key,
    required this.courseCode,
    required this.courseName,

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
                              TeacherClassPage(
                                className: courseName,
                                classCode: courseCode,
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
                              Text(courseCode,
                                  style: GoogleFonts.abel(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.white
                                    ),
                                  )),

                              //Subject Name
                              Text(courseName,
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

