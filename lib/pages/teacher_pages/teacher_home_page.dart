import 'package:blue_print/pages/teacher_pages/teacher_class_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class TeacherHomePage extends StatefulWidget {
  final String teacherUID;
  final String teacherName;
  const TeacherHomePage({super.key, required this.teacherUID, required this.teacherName});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50,),
          Text(widget.teacherName),
          Text(widget.teacherUID),
          SizedBox(
              height: 700,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("teacher")
                            .doc(widget.teacherUID)
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
                                  return TeacherClassTile(
                                    courseName: Class["className"],
                                    courseCode: Class["classCode"],
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
