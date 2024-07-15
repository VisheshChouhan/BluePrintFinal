
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
    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Container(

          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: primaryColor
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
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    child: Expanded(
                      child: Row(
                        children: [
                          Container(width: 10,
                            height:60,
                            color: blueColor,),
                          SizedBox(width: 20,
                            height: 10,),
                          //Picture of the subject
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(courseCode.toUpperCase(),
                                  style: GoogleFonts.abel(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.white
                                    ),
                                  )),

                              //Subject Name
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child:Text(courseName.toUpperCase(),
                                    style: GoogleFonts.abel(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Colors.white
                                      ),
                                    )),)
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

