import 'package:blue_print/features/roles/admin/presentation/pages/admin_home_page.dart';
import 'package:blue_print/features/roles/student/presentation/pages/student_home_page.dart';
import 'package:blue_print/features/roles/teacher/presentation/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';

import '../../assets/my_color_theme.dart';
import '../widgets/choice_box.dart';

class ChoiceForRoles extends StatefulWidget {
  const ChoiceForRoles({super.key});

  @override
  State<ChoiceForRoles> createState() => _ChoiceForRolesState();
}

class _ChoiceForRolesState extends State<ChoiceForRoles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(
          color: MyColorThemeTheme.whiteColor,
        ),
        centerTitle: true,
        title: const Text("Roles",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 170,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceBox(
                  text: "Student", onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentHomePage(),),);
                },
                ),
                ChoiceBox(
                  text: 'Teacher', onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherHomePage(),),);
                },
                ),
              ],
            ),
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceBox(
                  text: 'Coordinator', onPressed: () {  },
                ),
                ChoiceBox(
                  text: 'Admin', onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const AdminHomePage(),),);
                },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
