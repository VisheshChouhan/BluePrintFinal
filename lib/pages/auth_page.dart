import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blue_print/pages/loginOrRegisterPage.dart';
import 'package:blue_print/pages/login_page.dart';
// import 'package:blue_print/pages/teacher_dashboard.dart';
// import '../models/MyButton.dart';
// import 'teacher_profile_settings.dart';
class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot ){
          //User logged in
          if(snapshot.hasData){
            // return DashBoard();
          }
          if(!snapshot.hasData){
            return LoginOrRegisterPage();
          }
          else{
            return  Scaffold(
              backgroundColor: Colors.white,

              body: SafeArea(
                child: Column(
                  children:  [

                    Container(

                        height: 500,
                        child: Image(
                          image: AssetImage("lib/assets/splash_screen_teacher.png"),
                          fit: BoxFit.cover,
                        )),
                    SizedBox(height: 20),
                    Text("Acadnect",
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),),
                    SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text("Streamline Your Classroom ",
                          style: TextStyle(
                              fontSize: 15.0

                          )

                      ),
                    ),
                    Text("The App that Helps You Stay Ahead of Your Tasks"),

                    SizedBox(height: 30),
                    // MyButton(onTap: (){
                    //   Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (context) => DashBoard()),);
                    // }
                    //     , text: "Let's Go")
                  ],
                ),
              ),

            );
          }
        }
      ),
    );
  }
}
