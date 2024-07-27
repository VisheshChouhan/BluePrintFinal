import 'package:blue_print/pages/coordinator_pages/class_collection_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../assets/my_color_theme.dart';
import './profile_page.dart';
import '../splash_screen.dart';

class CoordinatorHomePage extends StatefulWidget {
  final String coordinatorUID;
  final String coordinatorName;
  final String coordinatorEmail;
  final String coordinatorPhone;
  final String coordinatorDepartment;
  const CoordinatorHomePage(
      {super.key,
        required this.coordinatorUID,
        required this.coordinatorName,
        required this.coordinatorEmail,
        required this.coordinatorPhone,
        required this.coordinatorDepartment,
      });

  @override
  State<CoordinatorHomePage> createState() => _CoordinatorHomePageState();
}

class _CoordinatorHomePageState extends State<CoordinatorHomePage> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
                      coordinatorName: widget.coordinatorName,
                      coordinatorEmail: widget.coordinatorEmail,
                      coordinatorPhone: widget.coordinatorPhone,
                      coordinatorDepartment: widget.coordinatorDepartment,
                    ),
                  ),
                );
              },
            ),

            // IconButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ProfilePage(
            //           coordinatorName: widget.coordinatorName,
            //           coordinatorEmail: widget.coordinatorEmail,
            //           coordinatorPhone: widget.coordinatorPhone,
            //           coordinatorDepartment: widget.coordinatorDepartment,
            //         ),
            //       ),
            //     );
            //   },
            //   icon: const Icon(
            //     Icons.account_circle_rounded,
            //     color: MyColorThemeTheme.whiteColor,
            //     size: 40,
            //   ),
            // ),


            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => SplashScreen())); // Close the drawer
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
          icon: Icon(
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
                widget.coordinatorName,
                style: GoogleFonts.openSans(
                    fontSize: 28, textStyle: TextStyle(color: Colors.white)),
              ),
              Text(
                widget.coordinatorUID,
                style: GoogleFonts.openSans(
                    fontSize: 15, textStyle: TextStyle(color: Colors.white70)),
              ),
              // SizedBox(height: 10)
            ]),
      ),
      body: const Center(child: ClassCollectionPage()),
    );
  }
}
