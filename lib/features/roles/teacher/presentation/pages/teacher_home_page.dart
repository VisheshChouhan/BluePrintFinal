import 'package:blue_print/features/roles/teacher/presentation/pages/profile_page.dart';
import 'package:blue_print/features/roles/teacher/presentation/widgets/labs.dart';
import 'package:blue_print/features/roles/teacher/presentation/widgets/theory.dart';
import 'package:flutter/material.dart';

import '../../../../../assets/my_color_theme.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teacher name',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: MyColorThemeTheme.whiteColor,
              ),
            ),
            Text(
              'Teacher',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: MyColorThemeTheme.whiteColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const ProfilePage(),),);
            },
            icon: const Icon(
              Icons.account_circle_rounded,
              color: MyColorThemeTheme.whiteColor,
              size: 40,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20.0,),
            ToggleButtons(
              // constraints: BoxConstraints(),
              borderRadius: BorderRadius.circular(10),
              selectedBorderColor: Theme.of(context).primaryColor,
              borderWidth: 2,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Theory', style: Theme.of(context).textTheme.headlineSmall,),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Labs', style: Theme.of(context).textTheme.headlineSmall,),
                ),
              ],
              isSelected: [_selectedIndex == 0, _selectedIndex == 1],
              onPressed: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            // Display content based on the selected section
            Expanded(
              child: _selectedIndex == 0 ? const Theory() : const Labs(),
            ),
          ],
        ),
      ),
    );
  }
}
