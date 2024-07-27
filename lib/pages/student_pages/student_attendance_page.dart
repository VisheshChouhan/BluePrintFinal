import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentAttendancePage extends StatefulWidget {
  final String classCode;
  final String className;
  final String studentCode;
  final String studentName;
  const StudentAttendancePage({super.key, required this.classCode,required this.className, required this.studentCode, required this.studentName});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);

  Future<DocumentSnapshot> fetchClassData() {
    // Fetch a single document from Firestore
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classCode) // Replace with your document ID
        .get();
  }

  Future<DocumentSnapshot> fetchStudentData() {
    // Fetch a single document from Firestore
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classCode)
    .collection("students")
    .doc(widget.studentCode)// Replace with your document ID
        .get();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Attendance of ${widget.studentName}",
                  style:
                  GoogleFonts.openSans(fontSize: 20, color: Colors.white),
                ),
                Text("Attendance of ${widget.studentName}",
                    style: GoogleFonts.openSans(
                        fontSize: 15, color: Colors.white70)),
              ])),
      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        FutureBuilder<DocumentSnapshot>(
          future: fetchClassData(), // Call the fetchDocument method
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
                  Text('Total Students: ${doc['totalNumberOfClasses']}',
                      style: GoogleFonts.openSans(
                          fontSize: 15
                      )),
                  // Add more fields as needed
                ],
              ),
            );
          },
        ),

        FutureBuilder<DocumentSnapshot>(
          future: fetchStudentData(), // Call the fetchDocument method
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
            // totalNumberOfClasses = doc['totalNumberOfClasses'];
            return Padding(
              padding: const EdgeInsets.fromLTRB(10,5,10,5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Classes Attended: ${doc['totalDaysPresent']}',
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
        Expanded(child:
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('students')
              .doc(widget.studentCode)
              .collection("classes")
              .doc(widget.classCode)
              .collection("attendance")
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

                return DateTile(data: data);
              },
            );
          },
        ),



        )
      ],)

    );
  }
}

class DateTile extends StatelessWidget {
  const DateTile({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
    Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
    return Container(
      height: 35,
      padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
      margin: EdgeInsets.fromLTRB(10, 3, 10, 3),
      decoration: BoxDecoration(
          color: blueColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin:EdgeInsets.fromLTRB(10, 3, 10, 3) ,
            width: 10,
            color: primaryColor,
          ),
          Text(
            data['date'],
            style: GoogleFonts.openSans(fontSize: 15, color: Colors.white),
          ),
        ],
      ),

      // You can customize ListTile with more fields as per your data structure
    );
  }
}