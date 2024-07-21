import 'package:blue_print/pages/splash_screen.dart';
import 'package:blue_print/pages/student_pages/student_class_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/roles/student/presentation/pages/profile_page.dart';

class StudentHomePage extends StatefulWidget {
  final String studentUID;
  final String studentName;
  final String studentEmail;
  final String studentPhone;
  final String studentDepartment;
  const StudentHomePage(
      {super.key,
        required this.studentUID,
        required this.studentName,
        required this.studentEmail,
        required this.studentPhone,
        required this.studentDepartment});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);

  @override
  Widget build(BuildContext context) {

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      // extendBodyBehindAppBar: true,
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
                  Navigator.pop(context); // Close the drawer
                  // Navigate to the home screen
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.account_circle_outlined),
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        studentName: widget.studentName,
                        studentEmail: widget.studentEmail,
                        studentPhone: widget.studentPhone,
                        studentDepartment: widget.studentDepartment,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> SplashScreen())); // Close the drawer
                  // Navigate to the contacts screen
                },
              ),
            ],
          ),
        ),
      // extendBody: true,
        appBar: AppBar(

          foregroundColor: primaryColor,
          backgroundColor: primaryColor,
          shadowColor: primaryColor,
          elevation: 0,
          leading: IconButton(icon:Icon(

            Icons.menu,
            size: 40,
            color: Colors.white,

          ),onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer
          },),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.studentUID,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white)),
              ),
              Text(
                widget.studentName,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
        body: Stack(children: [
          Column(
            children: [
              Container(
                height: 500,
                color: primaryColor,

              )
            ],
          ),

          SingleChildScrollView(child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              height: 100,
              color: Colors.transparent,

            ),

              Container(

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white

                  ),
                  margin: EdgeInsets.all(20),
                  height: 650,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                      final Class = snapshot.data!.docs[index];
                                      return StudentClassTile(
                                        className: Class["className"],
                                        classCode: Class["classCode"],
                                        studentCode: widget.studentUID,
                                        studentName: widget.studentName
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
          ))]));
  }
}
