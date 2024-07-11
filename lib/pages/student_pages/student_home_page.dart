import 'package:blue_print/pages/student_pages/student_class_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  final String studentUID;
  final String studentName;
  const StudentHomePage({super.key, required this.studentUID, required this.studentName});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50,),
          Text(widget.studentUID),
          Text(widget.studentName),
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
                            .orderBy("classCode")
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
                                  final Class =
                                  snapshot.data!.docs[index];
                                  return StudentClassTile(
                                    className: Class["className"],
                                    classCode: Class["classCode"],
                                    studentUID: widget.studentUID,
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
