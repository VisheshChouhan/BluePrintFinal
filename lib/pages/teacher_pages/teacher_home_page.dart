import 'package:blue_print/pages/teacher_pages/teacher_class_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/roles/teacher/presentation/pages/profile_page.dart';
import '../splash_screen.dart';

class TeacherHomePage extends StatefulWidget {
  final String teacherCode;
  final String teacherName;
  final String teacherEmail;
  final String teacherPhone;
  final String teacherDepartment;
  const TeacherHomePage(
      {super.key,
        required this.teacherCode,
        required this.teacherName,
        required this.teacherEmail,
        required this.teacherPhone,
        required this.teacherDepartment});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 152, 206, 1.0),
                ),
                child: Text(
                  'BluePrint',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        teacherName: widget.teacherName,
                        teacherEmail: widget.teacherEmail,
                        teacherPhone: widget.teacherPhone,
                        teacherDepartment: widget.teacherDepartment,
                      ),
                    ),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.account_circle_outlined),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to the settings screen
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          SplashScreen())); // Close the drawer
                  // Navigate to the contacts screen
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          foregroundColor: primaryColor,
          backgroundColor: primaryColor,
          shadowColor: primaryColor,
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.teacherName,
                  style: GoogleFonts.openSans(
                      fontSize: 28, textStyle: TextStyle(color: Colors.white)),
                ),
                Text(
                  widget.teacherCode,
                  style: GoogleFonts.openSans(
                      fontSize: 15,
                      textStyle: TextStyle(color: Colors.white70)),
                ),
                SizedBox(height: 10)
              ]),
        ),
        body: SingleChildScrollView(child:  Stack(
          children: [
            Container(
              height: 200,
              color: primaryColor,
            ),
            Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),

                  child: ClassListMethod(widget: widget),
                )
              ],
            )
          ],
        )));
  }
}

class ClassListMethod extends StatelessWidget {
  const ClassListMethod({
    super.key,
    required this.widget,
  });

  final TeacherHomePage widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          .doc(widget.teacherCode)
                          .collection("classes")
                          .orderBy("classCode")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final Class = snapshot.data!.docs[index];
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
                ])),
      ],
    );
  }
}
