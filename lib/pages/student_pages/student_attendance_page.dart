import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudentAttendancePage extends StatefulWidget {
  final String classCode;
  final String className;
  final String studentUID;
  const StudentAttendancePage({super.key, required this.classCode,required this.className, required this.studentUID});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50,),
          Text("Your Attendance"),
          SizedBox(
              height: 700,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("students")
                            .doc(widget.studentUID)
                            .collection("classes")
                        .doc(widget.classCode)
                        .collection("attendance")
                            .orderBy("date")
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final date =
                                  snapshot.data!.docs[index];
                                  return Text(
                                    date["date"]

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
                  ]
              )
          ),
        ],
      ),
    );
  }
}
