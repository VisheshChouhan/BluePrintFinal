import 'package:blue_print/assets/my_color_theme.dart';
import 'package:blue_print/models/my_textfield.dart';
import 'package:blue_print/pages/teacher_pages/custom_checkbox_tile.dart';
import 'package:blue_print/pages/teacher_pages/custom_map.dart';
import 'package:blue_print/sql_classes/attendance_detail_for_class.dart';
import 'package:blue_print/sql_classes/attendance_detail_for_students.dart';
import 'package:blue_print/sql_classes/sql_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../helper_classes/internet_connectivity_service.dart';

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
  late SQLiteDataBase handler;

  // For checking internet Connectivity
  final ConnectivityService _connectivityService = ConnectivityService();
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isConnected = true;

  bool _isStoringAttendance = false;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    //Sqlite Database helper
    handler = SQLiteDataBase();

    selectedStudentCodes = widget.initialPresentStudents;

    // For checking internet connectivity
    _connectivityStream = _connectivityService.connectivityStream;
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    _isConnected = await _connectivityService.isConnected();
    setState(() {});
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
      body: Stack(
        children: [
          Center(
            child: _isStoringAttendance ? CircularProgressIndicator(): null,
          ),
       SingleChildScrollView(
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
                    onPressed: _isStoringAttendance ?null: () async {
                      if (attendanceCode.text.isNotEmpty) {
                        await storeInSql();
                        await _checkConnection();
                        if (_isConnected) {
                          print('_isConnected');
                          print(_isConnected);
                          await sendFromSQLiteToFirebase();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              new SnackBar(
                                  content: Text("You are Offline.. \n The data will be stored in local Database.  ")));
                        }

                        // storeAttendance();
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
      ),]),
    );
  }

  Future<void> storeInSql() async {
    // SQLiteDataBase handler = SQLiteDataBase();
    // To refresh the content of finallyPresentStudentMap so that its current length got used
    setState(() {
      finallyPresentStudentMap;
      _isStoringAttendance = true;
    });
    // length of above map
    String finalPresentStudentMapLength =
        finallyPresentStudentMap.length.toString();

    // Today's date
    DateTime now = DateTime.now();
    String formattedDate =
        "${DateFormat('dd-MM-yyyy').format(now)}-${attendanceCode.text.toString().trim()}";

    // First we will store the class Data
    AttendanceDetailForClass attendanceDetailForClass =
        AttendanceDetailForClass(widget.classCode, formattedDate,
            finalPresentStudentMapLength, totalStudents.toString());
    List<AttendanceDetailForClass> listOfAttendanceDetailForClass = [
      attendanceDetailForClass
    ];
    await handler.insertInClassTable(listOfAttendanceDetailForClass);

    // Inserting into Student Table in Sqlite
    List<AttendanceDetailForStudents> listOfAttendanceDetailForStudents = [];

    for (int i = 0; i < finallyPresentStudentMap.length; i++) {
      String tempStudentCode =
          finallyPresentStudentMap.elementAt(i)["studentCode"];
      String tempStudentName =
          finallyPresentStudentMap.elementAt(i)["studentName"];

      AttendanceDetailForStudents attendanceDetailForStudents =
          AttendanceDetailForStudents(tempStudentCode, tempStudentName,
              widget.classCode, formattedDate);

      listOfAttendanceDetailForStudents.add(attendanceDetailForStudents);
    }

    await handler.insertInStudentTable(listOfAttendanceDetailForStudents);

    setState(() {

      _isStoringAttendance = false;
    });


  }

  Future<void> sendFromSQLiteToFirebase() async {
    // SQLiteDataBase handler = SQLiteDataBase();
    // To refresh the content of finallyPresentStudentMap so that its current length got used
    setState(() {
      finallyPresentStudentMap;
      _isStoringAttendance = true;
    });





    // For class Table
    List<AttendanceDetailForClass> listOfAttendanceDetailForClass =
        await handler.retrieveClassTable();
    for (var attendanceDetailForClass in listOfAttendanceDetailForClass) {
      await checkDateExistAndIncrementAndAddNumberOfPresentStudents(
          attendanceDetailForClass);
    }

    // For Student Table
    List<AttendanceDetailForStudents> listOfAttendanceDetailForStudents =
        await handler.retrieveStudentTable();
    for (var attendanceDetailForStudents in listOfAttendanceDetailForStudents) {
      await checkStudentExistAndUpdateAtEachPlace(attendanceDetailForStudents);
    }

    setState(() {

      _isStoringAttendance = false;
    });
  }

  Future<void> checkDateExistAndIncrementAndAddNumberOfPresentStudents(
      AttendanceDetailForClass attendanceDetailForClass) async {
    String classTableClassCode = attendanceDetailForClass.classCode;
    String classTableFormattedDate = attendanceDetailForClass.formattedDate;
    String classTableFinalPresentStudentMapLength =
        attendanceDetailForClass.finalPresentStudentMapLength;
    String classTableTotalStudents = attendanceDetailForClass.totalStudents;
    int? classTableid = attendanceDetailForClass.id;

    try {
      // Fetch the document from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(
              classTableClassCode) // .doc(widget.classCode) // Replace with your document ID
          .collection("attendance")
          .doc(classTableFormattedDate) // .doc(formattedDate)
          .get();

      if (doc.exists) {
        // Document exists, handle the data
        print('Document Data: ${doc.data()}');
      } else {
        // Document does not exist, perform the operation
        print('Document does not exist. Performing operation...');
        // Example operation: Add a new document
        // This increment the number of total classes by one
        DocumentReference classRef = db
            .collection('classes')
            .doc(classTableClassCode); //.doc(widget.classCode);

        DocumentReference classAttendanceDateReg =
            db // will refer to attendance of particular date
                .collection("classes")
                .doc(classTableClassCode) // .doc(widget.classCode)
                .collection("attendance")
                .doc(classTableFormattedDate); //.doc(formattedDate);

        db.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(classRef);

          if (!snapshot.exists) {
            throw Exception("Document does not exist!");
          }

          int currentValue = snapshot["totalNumberOfClasses"];
          int newValue = currentValue + 1;
          transaction.update(classRef, {'totalNumberOfClasses': newValue});

          transaction.set(classAttendanceDateReg, {
            "date": classTableFormattedDate, //"date": formattedDate,
            "totalPresentStudents":
                classTableFinalPresentStudentMapLength, //finallyPresentStudentMap.length.toString(),
            "totalStudents": classTableTotalStudents //totalStudents
          });
        }).then((_) async {
          // Now we will delete entry from sql table cause now its in firebase
          await handler.deleteClassRow(classTableid!);

          print("Transaction successfully committed!");
        }).catchError((error) {
          print("Transaction failed: $error");
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //     new SnackBar(content: Text("Data Successfully stored")));
      }
      // Its is added above in transaction
      // Added here so that only have to maintain one function
      // Adding number of present Students
      // db
      //     .collection("classes")
      //     .doc(widget.classCode)
      //     .collection("attendance")
      //     .doc(formattedDate)
      //     .set({
      //   "date": formattedDate,
      //   "totalPresentStudents": finallyPresentStudentMap.length.toString(),
      //   "totalStudents": totalStudents
      // });
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Future<void> checkStudentExistAndUpdateAtEachPlace(
      AttendanceDetailForStudents attendanceDetailForStudents) async {
    int? studentTableId = attendanceDetailForStudents.id;
    String studentTableStudentCode = attendanceDetailForStudents.studentCode;
    String studentTableStudentName = attendanceDetailForStudents.studentName;
    String studentTableClassCode = attendanceDetailForStudents.classCode;
    String studentTableFormattedDate =
        attendanceDetailForStudents.formattedDate;

    try {
      // Document does not exist, perform the operation
      print('Document does not exist. Performing operation...');
      // Example operation: Add a new document
      // This increment the number of total classes by one
      DocumentReference classStudentAttendance = db
          .collection('classes')
          .doc(studentTableClassCode) // .doc(widget.classCode)
          .collection("students")
          .doc(studentTableStudentCode); // .doc(studentUID);

      DocumentReference particularDateAttendance = db
          .collection("classes")
          .doc(studentTableClassCode) // .doc(widget.classCode)
          .collection("attendance")
          .doc(studentTableFormattedDate) // .doc(formattedDate)
          .collection("presentStudents")
          .doc(studentTableStudentCode); //.doc(tempStudentCode);

      DocumentReference studentClassAttendance = db
          .collection("students")
          .doc(studentTableStudentCode) // .doc(tempStudentCode)
          .collection("classes")
          .doc(studentTableClassCode) // .doc(widget.classCode)
          .collection("attendance")
          .doc(studentTableFormattedDate); // .doc(formattedDate);

      Map<String, dynamic> tempStudentMap = {
        "studentCode": studentTableStudentCode,
        "studentName": studentTableStudentName
      };

      db.runTransaction((transaction) async {
        DocumentSnapshot snapshot =
            await transaction.get(classStudentAttendance);

        if (!snapshot.exists) {
          throw Exception("Document does not exist!");
        }

        // for classStudentAttendance Entry
        int currentValue = snapshot["totalDaysPresent"];
        int newValue = currentValue + 1;
        transaction
            .update(classStudentAttendance, {'totalDaysPresent': newValue});

        // For particularDateAttendance Entry
        transaction.set(particularDateAttendance, tempStudentMap);

        // For student Class Attendance
        transaction
            .set(studentClassAttendance, {"date": studentTableFormattedDate});
      }).then((_) async {
        await handler.deleteStudentRow(studentTableId!);
        print("Transaction successfully committed!");
      }).catchError((error) {
        print("Transaction failed: $error");
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //     new SnackBar(content: Text("Data Successfully stored")));
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  // Future<void> storeAttendance() async {
  //   setState(() {
  //     finallyPresentStudentMap;
  //   });
  //   // Get the current date
  //   DateTime now = DateTime.now();
  //   // Format the date
  //   String formattedDate =
  //       "${DateFormat('dd-MM-yyyy').format(now)}-${attendanceCode.text.toString().trim()}";
  //
  //   //This function increases the number of classes
  //   await checkDateExistAndIncrementAndAddNumberOfPresentStudents(
  //       formattedDate);
  //   //        ^^^^^^^ /\
  //   //        ||||||| ||
  //   //  Added in above function
  //   // Adding number of present Students
  //   // db
  //   //     .collection("classes")
  //   //     .doc(widget.classCode)
  //   //     .collection("attendance")
  //   //     .doc(formattedDate)
  //   //     .set({
  //   //   "date": formattedDate,
  //   //   "totalPresentStudents": finallyPresentStudentMap.length.toString(),
  //   //   "totalStudents": totalStudents
  //   // });
  //
  //   print("finallyPresentStudentMap");
  //   print(finallyPresentStudentMap.toString());
  //   for (int i = 0; i < finallyPresentStudentMap.length; i++) {
  //     String tempStudentCode =
  //         finallyPresentStudentMap.elementAt(i)["studentCode"];
  //     String tempStudentName =
  //         finallyPresentStudentMap.elementAt(i)["studentName"];
  //
  //     await checkStudentExistAndIncrement(tempStudentCode);
  //     db
  //         .collection("classes")
  //         .doc(widget.classCode)
  //         .collection("attendance")
  //         .doc(formattedDate)
  //         .collection("presentStudents")
  //         .doc(tempStudentCode)
  //         .set(finallyPresentStudentMap.elementAt(i).getInnerMap());
  //
  //     db
  //         .collection("students")
  //         .doc(tempStudentCode)
  //         .collection("classes")
  //         .doc(widget.classCode)
  //         .collection("attendance")
  //         .doc(formattedDate)
  //         .set({"date": formattedDate});
  //   }
  //
  //   // // This increment the number of total classes by one
  //   // DocumentReference docRef = db.collection('classes').doc(widget.classCode);
  //   // db.runTransaction((transaction) async {
  //   //   DocumentSnapshot snapshot = await transaction.get(docRef);
  //   //
  //   //   if (!snapshot.exists) {
  //   //     throw Exception("Document does not exist!");
  //   //   }
  //   //
  //   //   int currentValue = snapshot["totalNumberOfClasses"];
  //   //   int newValue = currentValue + 1;
  //   //   transaction.update(docRef, {'totalNumberOfClasses': newValue});
  //   // }).then((_) {
  //   //   print("Transaction successfully committed!");
  //   // }).catchError((error) {
  //   //   print("Transaction failed: $error");
  //   // });
  //   //
  //   // ScaffoldMessenger.of(context)
  //   //     .showSnackBar(new SnackBar(content: Text("Data Successfully stored")));
  // }
}
