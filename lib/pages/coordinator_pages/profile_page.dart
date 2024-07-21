import 'package:blue_print/features/roles/student/presentation/widgets/basic_info.dart';
import 'package:blue_print/features/roles/student/presentation/widgets/info_text.dart';
import 'package:blue_print/features/roles/student/presentation/widgets/profile_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../splash_screen.dart';

class ProfilePage extends StatefulWidget {
  final String coordinatorName;
  final String coordinatorEmail;
  final String coordinatorPhone;
  final String coordinatorDepartment;
  const ProfilePage({super.key, required this.coordinatorName, required this.coordinatorEmail, required this.coordinatorPhone, required this.coordinatorDepartment});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ProfileImage(),
                SizedBox(height: 10,),
                InfoText(text: widget.coordinatorName, style: Theme.of(context).textTheme.headlineMedium!),
                SizedBox(height: 20.0,),

                BasicInfo(onPressed: (){}, text: widget.coordinatorEmail,),
                SizedBox(height: 10.0,),
                BasicInfo(onPressed: (){}, text: widget.coordinatorDepartment,),
                SizedBox(height: 10.0,),
                BasicInfo(onPressed: (){}, text: widget.coordinatorPhone, iconData: Icons.edit,),
                SizedBox(height: 10.0,),
                BasicInfo(onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> SplashScreen())); // Close the drawer
                  // Navigate to the contacts screen
                }, text: 'LogOut', iconData: Icons.logout,),
                SizedBox(height: 10.0,),
                // BasicInfo(onPressed: (){}, text: 'Change password', iconData: Icons.edit,),
                // SizedBox(height: 10.0,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
