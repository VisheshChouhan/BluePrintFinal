import 'package:blue_print/features/roles/admin/presentation/pages/profile_page.dart';
import 'package:blue_print/features/roles/admin/presentation/widgets/home_page_option.dart';
import 'package:flutter/material.dart';

import '../../../../../assets/my_color_theme.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
              'Admin name',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: MyColorThemeTheme.whiteColor,
              ),
            ),
            Text(
              'Admin',
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const ProfilePage(adminName: '', adminEmail: '', adminPhone: '', adminDepartment: '',),),);
            },
            icon: const Icon(
              Icons.account_circle_rounded,
              color: MyColorThemeTheme.whiteColor,
              size: 40,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50,),
              HomePageOption(onPressed: (){}, text: 'Connect'),
              SizedBox(height: 20.0),
              HomePageOption(onPressed: (){}, text: 'Enroll Student'),
              SizedBox(height: 20.0),
              HomePageOption(onPressed: (){}, text: 'Delete Student'),
              SizedBox(height: 120,),
            ],
          ),
        ),
      ),
    );
  }
}
