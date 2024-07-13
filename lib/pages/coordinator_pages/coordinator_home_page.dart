import 'package:blue_print/pages/coordinator_pages/class_collection_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoordinatorHomePage extends StatefulWidget {
  final String coordinatorUID;
  final String coordinatorName;
  const CoordinatorHomePage(
      {super.key, required this.coordinatorUID, required this.coordinatorName});

  @override
  State<CoordinatorHomePage> createState() => _CoordinatorHomePageState();
}

class _CoordinatorHomePageState extends State<CoordinatorHomePage> {
  Color primaryColor = const Color.fromRGBO(1, 94, 127, 1);
  Color blueColor = const Color.fromRGBO(0, 152, 206, 1.0);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: primaryColor,
          backgroundColor: primaryColor,
          shadowColor: primaryColor,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.coordinatorUID,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white)),
              ),
              Text(
                widget.coordinatorName,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white)),
              )
            ],
          ),
          bottom: TabBar(
            indicatorColor: blueColor,
            labelColor: Colors.white,
            // indicator: UnderlineTabIndicator(),
            tabs: [
              Tab(
                  icon: Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  text:'Home'),
              // Tab(
              //     icon: Icon(
              //       Icons.event,
              //       color: Colors.white,
              //     ),
              //     text: 'All Attendance'),
              Tab(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  text: 'Delete Students'),

            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: ClassCollectionPage()),
            // Center(child: Text('Settings Page')),
            Center(child: Text('Delete Student Page')),

          ],
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Column(
  //       children: [
  //         SizedBox(
  //           height: 40,
  //         ),
  //         Text("Coordinator Name here"),
  //         SizedBox(
  //           height: 40,
  //         ),
  //         ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).push(MaterialPageRoute(
  //                   builder: (context) => ClassCollectionPage()));
  //             },
  //             child: Text("All Classes")
  //         ),
  //         ElevatedButton(onPressed: null, child: Text("View Attendance")),
  //         ElevatedButton(onPressed: null, child: Text("Delete Student"))
  //       ],
  //     ),
  //   );
  // }
}
