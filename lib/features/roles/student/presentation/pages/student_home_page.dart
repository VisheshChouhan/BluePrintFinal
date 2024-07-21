import 'package:blue_print/assets/my_color_theme.dart';
import 'package:blue_print/features/roles/student/presentation/pages/profile_page.dart';
import 'package:blue_print/features/roles/student/presentation/widgets/subjects.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {

  List<Subjects> _buildGridCards(int count) {
    List<Subjects> cards = List.generate(
      count,
          (int index) {
        return Subjects(onPressed: (){}, text1: 'Subject Name-(CO-XXXX)', text2: 'Teacher name');
      },
    );
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Divyanshu jain',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: MyColorThemeTheme.whiteColor,
              ),
            ),
            Text(
              'Student',
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(studentName: '', studentEmail: '', studentPhone: '', studentDepartment: '',),),);
              },
              icon: const Icon(
                Icons.account_circle_rounded,
                color: MyColorThemeTheme.whiteColor,
                size: 40,
              ),
          ),
        ],
      ),
      body: GridView.count(
          crossAxisCount: 1,
          padding: const EdgeInsets.all(16.0),
          childAspectRatio: 16/7,
          children: _buildGridCards(7) // Replace
      ),
    );
  }
}
