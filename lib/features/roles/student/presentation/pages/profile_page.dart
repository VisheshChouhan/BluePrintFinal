import 'package:blue_print/features/roles/student/presentation/widgets/basic_info.dart';
import 'package:blue_print/features/roles/student/presentation/widgets/info_text.dart';
import 'package:blue_print/features/roles/student/presentation/widgets/profile_image.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
                InfoText(text: 'Divyanshu Jain', style: Theme.of(context).textTheme.headlineMedium!),
                SizedBox(height: 5,),
                InfoText(text: '(YYYY - YYYY)', style: Theme.of(context).textTheme.bodyLarge!),
                SizedBox(height: 20.0,),

                BasicInfo(onPressed: (){}, text: 'gs2119063@sgsitsindore.in',),
                SizedBox(height: 10.0,),
                BasicInfo(onPressed: (){}, text: 'Computer Science & Engineering',),
                SizedBox(height: 10.0,),
                BasicInfo(onPressed: (){}, text: 'Phone no.', iconData: Icons.edit,),
                SizedBox(height: 10.0,),
                BasicInfo(onPressed: (){}, text: 'Address', iconData: Icons.edit,),
                SizedBox(height: 10.0,),
                BasicInfo(onPressed: (){}, text: 'Change password', iconData: Icons.edit,),
                SizedBox(height: 10.0,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
