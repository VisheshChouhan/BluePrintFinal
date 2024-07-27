import 'package:blue_print/pages/teacher_pages/teacher_attendance_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../coordinator_pages/attendance_date_tile.dart';
import '../coordinator_pages/coordinator_student_attendance_page.dart';

class TeacherClassPage extends StatefulWidget {
  final String classCode;
  final String className;
  const TeacherClassPage(
      {super.key, required this.classCode, required this.className});

  @override
  State<TeacherClassPage> createState() => _TeacherClassPageState();
}

class _TeacherClassPageState extends State<TeacherClassPage> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        widget.className.toUpperCase(),
                        style: GoogleFonts.openSans(
                            textStyle: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Text(
                      widget.classCode,
                      style: GoogleFonts.openSans(
                          fontSize: 15,
                          textStyle: TextStyle(color: Colors.white54)),
                    ),
                  ]),
              bottom: TabBar(
                indicatorColor: blueColor,
                labelColor: Colors.white,
                // indicator: UnderlineTabIndicator(),
                tabs: const [
                  Tab(
                      icon: Icon(
                        Icons.event,
                        color: Colors.white,
                      ),
                      text: 'Mark Attendance'),
                  Tab(
                      icon: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                      text: 'View by Dates'),
                  Tab(
                      icon: Icon(
                        Icons.school,
                        color: Colors.white,
                      ),
                      text: 'View Students'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                TeacherAttendancePage(
                  className: widget.className,
                  classCode: widget.classCode,
                ),
                AttendancyByDates(
                  widget: widget,
                ),
                AttendanceByStudents(
                  widget: widget,
                )
              ],
            )));
  }
}

class AttendanceByStudents extends StatelessWidget {
  final TeacherClassPage widget;
  const AttendanceByStudents({super.key, required this.widget});
  Future<DocumentSnapshot> fetchDocument() {
    // Fetch a single document from Firestore
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classCode) // Replace with your document ID
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FutureBuilder<DocumentSnapshot>(
        future: fetchDocument(), // Call the fetchDocument method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // return Center(child: Text('Document does not exist'));
          }

          final doc = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(10,5,10,5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Classes: ${doc['totalNumberOfClasses']}',
                    style: GoogleFonts.openSans(
                        fontSize: 15
                    )),
                // Add more fields as needed
              ],
            ),
          );
        },
      ),


      Container(
        child: Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classCode)
            .collection("students")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Access Firestore documents
          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              // Extract data from each document
              final Map<String, dynamic> data =
                  documents[index].data() as Map<String, dynamic>;

              return StudentDetailTile(
                data: data,
                classCode: widget.classCode,
              );
            },
          );
        },
      ),
    )
    )]);
  }
}

class StudentDetailTile extends StatelessWidget {
  final String classCode;
  const StudentDetailTile({
    super.key,
    required this.data,
    required this.classCode,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CoordinatorStudentAttendancePage(
                    studentCode: data['studentCode'].toString().toUpperCase(),
                    studentName: data['studentName'].toString().toUpperCase(),
                    classCode: classCode,
                  )));
        },
        child: Container(
          height: 55,
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          margin: EdgeInsets.fromLTRB(10, 3, 10, 3),
          decoration: BoxDecoration(
              color: blueColor, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 40,
                color: primaryColor,
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['studentName'].toString().toUpperCase(),
                    style:
                        GoogleFonts.openSans(fontSize: 15, color: Colors.white),
                  ),
                  Text(
                    data['studentCode'].toString().toUpperCase(),
                    style:
                        GoogleFonts.openSans(fontSize: 15, color: Colors.white),
                  ),
                ],
              )
            ],
          ),

          // You can customize ListTile with more fields as per your data structure
        ));
  }
}

class AttendancyByDates extends StatelessWidget {
  const AttendancyByDates({
    super.key,
    required this.widget,
  });

  final TeacherClassPage widget;

  Future<DocumentSnapshot> fetchDocument() {
    // Fetch a single document from Firestore
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classCode) // Replace with your document ID
        .get();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<DocumentSnapshot>(
          future: fetchDocument(), // Call the fetchDocument method
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              // return Center(child: Text('Document does not exist'));
            }

            final doc = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.fromLTRB(10,5,10,5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Classes: ${doc['totalNumberOfClasses']}',
                      style: GoogleFonts.openSans(
                        fontSize: 15
                      )),
                  // Add more fields as needed
                ],
              ),
            );
          },
        ),
        Divider(),
        SizedBox(
            height: 700,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("classes")
                          .doc(widget.classCode)
                          .collection("attendance")
                          .orderBy("date")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final date = snapshot.data!.docs[index];
                                return AttendanceDateTile(
                                  date: date["date"],
                                  presentStudents: date["totalPresentStudents"],
                                  totalstudents: date["totalStudents"].toString()    ,
                                  classCode: widget.classCode,
                                  className: widget.className,
                                );
                              });
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error:${snapshot.error}'),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ])),
      ],
    );
  }
}
