import 'package:blue_print/assets/my_color_theme.dart';
import 'package:blue_print/models/my_textfield.dart';
import 'package:blue_print/pages/teacher_pages/custom_checkbox_tile.dart';
import 'package:blue_print/pages/teacher_pages/custom_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  int initiallyPresentStudentsLength = 0;
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
        CustomMap temp = new CustomMap(
            {'studentCode': studentCode, 'studentName': studentName});
        finallyPresentStudentMap.add(temp);
      } else {
        selectedStudentCodes.remove(studentCode);
        CustomMap temp = new CustomMap(
            {'studentCode': studentCode, 'studentName': studentName});
        finallyPresentStudentMap.remove(temp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        foregroundColor: MyColorThemeTheme.visheshPrimaryColor,
        backgroundColor: MyColorThemeTheme.visheshPrimaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.classCode.toUpperCase(),
              style: GoogleFonts.openSans(color: Colors.white),
            ),
            Text(
              widget.className.toUpperCase(),
              style: GoogleFonts.openSans(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),

            // Text(selectedStudentCodes.toString()),
            // Text("Absent Students : " +
            //     (totalStudents - selectedStudentCodes.length).toString()),
            // const Divider(),
            SingleChildScrollView(
                child: Expanded(
              child: SizedBox(
                  height: 600,
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
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                totalStudents = 0;
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      totalStudents += 1;

                                      final student =
                                          snapshot.data!.docs[index];

                                      //Adding already present student in presentStudentMap
                                      if (selectedStudentCodes.contains(
                                          student["studentCode"].toString())) {
                                        CustomMap temp = new CustomMap({
                                          'studentCode': student["studentCode"],
                                          'studentName': student["studentName"],
                                        });

                                        finallyPresentStudentMap.add(temp);

                                        initiallyPresentStudentsLength += 1;
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
            )),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    // color: MyColorThemeTheme.blueColor,
                    child: Center(
                      child: Text(
                        "Present Students: ${finallyPresentStudentMap.length}",
                        style: GoogleFonts.openSans(
                            color: MyColorThemeTheme.greenColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 30,
                    // color: MyColorThemeTheme.blueColor,
                    child: Center(
                      child: Text(
                        "Absent Students: ${totalStudents - finallyPresentStudentMap.length}",
                        style: GoogleFonts.openSans(
                            color: MyColorThemeTheme.redColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
            MyTextField(
                controller: attendanceCode,
                hintText: "Enter Unique Attendance Code",
                obscureText: false),
            // Text(finallyPresentStudentMap.toString()),
            const SizedBox(
              height: 10,
            ),
            Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(),
                        foregroundColor: Colors.white,
                        backgroundColor: MyColorThemeTheme.blueColor),
                    onPressed: () {
                      if (attendanceCode.text.isNotEmpty) {
                        storeAttendance();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please Enter a Unique Attendance Code")));
                      }
                    },
                    child: const Text("Store Attendance")))
          ],
        ),
      ),
    );
  }

  Future<void> checkDateExistAndIncrement(String formattedDate) async {
    try {
      // Fetch the document from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classCode) // Replace with your document ID
          .collection("attendance")
          .doc(formattedDate)
          .get();

      if (doc.exists) {
        // Document exists, handle the data
        print('Document Data: ${doc.data()}');
      } else {
        // Document does not exist, perform the operation
        print('Document does not exist. Performing operation...');
        // Example operation: Add a new document
        // This increment the number of total classes by one
        DocumentReference docRef =
            db.collection('classes').doc(widget.classCode);
        db.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(docRef);

          if (!snapshot.exists) {
            throw Exception("Document does not exist!");
          }

          int currentValue = snapshot["totalNumberOfClasses"];
          int newValue = currentValue + 1;
          transaction.update(docRef, {'totalNumberOfClasses': newValue});
        }).then((_) {
          print("Transaction successfully committed!");
        }).catchError((error) {
          print("Transaction failed: $error");
        });

        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(content: Text("Data Successfully stored")));
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }


  Future<void> checkStudentExistAndIncrement(String studentUID) async {
    try {

        // Document does not exist, perform the operation
        print('Document does not exist. Performing operation...');
        // Example operation: Add a new document
        // This increment the number of total classes by one
        DocumentReference docRef =
        db.collection('classes').doc(widget.classCode).collection("students").doc(studentUID);
        db.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(docRef);

          if (!snapshot.exists) {
            throw Exception("Document does not exist!");
          }

          int currentValue = snapshot["totalDaysPresent"];
          int newValue = currentValue + 1;
          transaction.update(docRef, {'totalDaysPresent': newValue});
        }).then((_) {
          print("Transaction successfully committed!");
        }).catchError((error) {
          print("Transaction failed: $error");
        });

        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(content: Text("Data Successfully stored")));

    } catch (e) {
      print('Error fetching document: $e');
    }
  }



  Future<void> storeAttendance() async {
    setState(() {
      finallyPresentStudentMap;
    });
    // Get the current date
    DateTime now = DateTime.now();
    // Format the date
    String formattedDate = "${DateFormat('dd-MM-yyyy').format(now)}-${attendanceCode.text.toString().trim()}";

    //This function increases the number of classes
    await checkDateExistAndIncrement(formattedDate);

    // Adding number of present Students
    db
        .collection("classes")
        .doc(widget.classCode)
        .collection("attendance")
        .doc(formattedDate)
        .set({
      "date": formattedDate,
      "totalPresentStudents": finallyPresentStudentMap.length.toString(),
      "totalStudents": totalStudents
    });

    print("finallyPresentStudentMap");
    print(finallyPresentStudentMap.toString());
    for (int i = 0; i < finallyPresentStudentMap.length; i++) {
        String tempStudentCode =
            finallyPresentStudentMap.elementAt(i)["studentCode"];
        String tempStudentName =
            finallyPresentStudentMap.elementAt(i)["studentName"];

        await checkStudentExistAndIncrement(tempStudentCode);
        db
            .collection("classes")
            .doc(widget.classCode)
            .collection("attendance")
            .doc(formattedDate)
            .collection("presentStudents")
            .doc(tempStudentCode)
            .set(finallyPresentStudentMap.elementAt(i).getInnerMap());

        db
            .collection("students")
            .doc(tempStudentCode)
            .collection("classes")
            .doc(widget.classCode)
            .collection("attendance")
            .doc(formattedDate)
            .set({"date": formattedDate});
    }



    // // This increment the number of total classes by one
    // DocumentReference docRef = db.collection('classes').doc(widget.classCode);
    // db.runTransaction((transaction) async {
    //   DocumentSnapshot snapshot = await transaction.get(docRef);
    //
    //   if (!snapshot.exists) {
    //     throw Exception("Document does not exist!");
    //   }
    //
    //   int currentValue = snapshot["totalNumberOfClasses"];
    //   int newValue = currentValue + 1;
    //   transaction.update(docRef, {'totalNumberOfClasses': newValue});
    // }).then((_) {
    //   print("Transaction successfully committed!");
    // }).catchError((error) {
    //   print("Transaction failed: $error");
    // });
    //
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(new SnackBar(content: Text("Data Successfully stored")));
  }
}
