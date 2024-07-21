import 'package:blue_print/pages/coordinator_pages/coordinator_home_page.dart';
import 'package:blue_print/pages/helper_pages/connect_page.dart';
import 'package:blue_print/pages/home_page.dart';
import 'package:blue_print/pages/student_pages/student_home_page.dart';
import 'package:blue_print/pages/teacher_pages/teacher_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:teachers_app/models/MyButton.dart';
// import 'package:teachers_app/pages/NavigationBar.dart';
import 'package:blue_print/pages/loginOrRegisterPage.dart';
import 'package:blue_print/pages/login_page.dart';

import '../features/roles/admin/presentation/pages/admin_home_page.dart';
import 'admin_pages/admin_home_page.dart';
// import 'package:teachers_app/pages/teacher_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check whether the user is logged in or not
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
        );
      } else {
        String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

        FirebaseFirestore db = FirebaseFirestore.instance;

        final docRef = db.collection("users").doc(currentUserId);

        await docRef.get().then(
          (DocumentSnapshot doc) async {
            final data = doc.data() as Map<String, dynamic>;
            // print("Data");
            // print(data);

            // Registering Each one in their respective Collection in database

            if ("admin" == data["role"].toString()) {
              Navigator.of(context).pushReplacement(
                // MaterialPageRoute(builder: (context) => ConnectPage()),
                MaterialPageRoute(builder: (context) => AdminHomePageOld(
                  adminName: data["name"],
                  adminEmail: data["email"],
                  adminPhone: data["phone"],
                  adminDepartment: data["department"],
                  adminUniqueId: data["uniqueId"],
                )),
              );
            } else if ("coordinator" == data["role"].toString()) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => CoordinatorHomePage(
                        coordinatorUID: data["uniqueId"],
                        coordinatorName: data["name"])),
              );
            } else if ("teacher" == data["role"].toString()) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => TeacherHomePage(
                        teacherCode: data["uniqueId"],
                        teacherName: data["name"])),
              );
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => StudentHomePage(
                      studentUID: data["studentCode"],
                      studentName: data["studentName"])));
            }
          },
          onError: (e) => print("Error getting document: $e"),
        );

        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => HomePage()),
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const  Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center ,
          crossAxisAlignment: CrossAxisAlignment.center,


          children: [
            // Container(
            //
            //   height: 500,
            //     child: Image(
            //       image: AssetImage("lib/assets/splash_screen_teacher.png"),
            //       fit: BoxFit.cover,
            //     )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    SizedBox(height: 20),
                    Text(
                      "BluePrint",
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text("Streamline Your Attendance ",
                          style: TextStyle(fontSize: 15.0)),
                    ),
                  ],
                )


            ],)

            // Text("The App that Helps You Stay Ahead of Your Tasks"),

            // SizedBox(height: 30),
            // MyButton(onTap: (){
            //   Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => DashBoard()),);
            // }
            //     , text: "Let's Go")
          ],
        ),
      ),
    );
  }
}
