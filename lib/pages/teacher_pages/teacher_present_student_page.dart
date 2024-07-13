import 'package:blue_print/models/my_textfield.dart';
import 'package:blue_print/pages/teacher_pages/custom_checkbox_tile.dart';
import 'package:blue_print/pages/teacher_pages/custom_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeacherPresentStudentPage extends StatefulWidget {
  final Set<dynamic> initialPresentStudents;
  final String classCode;
  final String className;
  const TeacherPresentStudentPage(
      {super.key,
      required this.initialPresentStudents,
      required this.classCode,
      required this.className});

  @override
  State<TeacherPresentStudentPage> createState() =>
      _TeacherPresentStudentPageState();
}

class _TeacherPresentStudentPageState extends State<TeacherPresentStudentPage> {
  Set<dynamic> selectedStudentCodes = {};
  Set<CustomMap> finallyPresentStudentMap = {};
  int totalStudents = 0;
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController attendanceCode = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    selectedStudentCodes = widget.initialPresentStudents;
    super.initState();
  }

  void onCheckboxChanged(
      String studentCode, String studentName, bool isChecked) {
    setState(() {
      if (isChecked) {
        selectedStudentCodes.add(studentCode);
        CustomMap temp = new CustomMap({'studentCode': studentCode, 'studentName': studentName});
        finallyPresentStudentMap
            .add(temp);
      } else {
        selectedStudentCodes.remove(studentCode);
        CustomMap temp = new CustomMap({'studentCode': studentCode, 'studentName': studentName});
        finallyPresentStudentMap
            .remove(temp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
            ),
            Text(widget.classCode),
            Text(widget.className),
            Text("Present Students: " + selectedStudentCodes.length.toString()),
            Text("Absent Students : " +
                (totalStudents - selectedStudentCodes.length).toString()),
            Divider(),
            SizedBox(
                height: 500,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("classes")
                              .doc(widget.classCode)
                              .collection("students")
                              .orderBy("studentName")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    totalStudents += 1;

                                    final student = snapshot.data!.docs[index];

                                    //Adding already present student in presentStudentMap
                                    if (selectedStudentCodes.contains(
                                        student["studentCode"].toString())) {
                                      CustomMap temp = new CustomMap({
                                        'studentCode': student["studentCode"],
                                        'studentName': student["studentName"],
                                      });

                                      finallyPresentStudentMap.add(temp);

                                    }

                                    return CustomCheckboxTile(
                                      studentName: student["studentName"],
                                      studentCode: student["studentCode"],
                                      isChecked: widget.initialPresentStudents
                                          .contains(student["studentCode"]),
                                      onCheckboxChanged: onCheckboxChanged,
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
            Divider(),
            MyTextField(
                controller: attendanceCode,
                hintText: "Enter Unique Attendance Code",
                obscureText: false),
            Text(finallyPresentStudentMap.toString()),
            ElevatedButton(onPressed: (){
              if(attendanceCode.text.isNotEmpty){
              storeAttendance();}
              else{
                ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Please Enter a Unique Attendance Code")));
              }
              }, child: Text("Store Attendance"))
          ],
        ),
      ),
    );
  }

  void storeAttendance() {
    setState(() {
      finallyPresentStudentMap;
    });
    // Get the current date
    DateTime now = DateTime.now();
    // Format the date
    String formattedDate = DateFormat('dd-MM-yyyy').format(now) + "-"+
        attendanceCode.text.toString().trim();
    // Adding number of present Students
    db
        .collection("classes")
        .doc(widget.classCode)
        .collection("attendance")
        .doc(formattedDate)

        .set({"date": formattedDate, "totalPresentStudents": finallyPresentStudentMap.length});

    print("finallyPresentStudentMap");
    print(finallyPresentStudentMap.toString());
    for (int i = 0; i < finallyPresentStudentMap.length; i++) {
      String tempStudentCode = finallyPresentStudentMap.elementAt(i)["studentCode"];
      String tempStudentName = finallyPresentStudentMap.elementAt(i)["studentName"];
      db
          .collection("classes")
          .doc(widget.classCode)
          .collection("attendance")
          .doc(formattedDate)
          .collection("presentStudents")
          .doc(tempStudentCode)
          .set(finallyPresentStudentMap.elementAt(i).getInnerMap());


      db.collection("students")
          .doc(tempStudentCode)
          .collection("classes")
          .doc(widget.classCode)
          .collection("attendance")
          .doc(formattedDate)
          .set({"date": formattedDate});
    }



    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Data Successfully stored")));
  }
}
