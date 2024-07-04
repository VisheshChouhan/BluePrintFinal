import 'package:blue_print/pages/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper_classes/database.dart';
import '../models/MyButton.dart';
import '../models/my_textfield.dart';
import 'home_page.dart';
// import 'package:teachers_app/models/MyButton.dart';
// import 'package:teachers_app/models/my_textfield.dart';
// import 'package:teachers_app/models/squareTile.dart';
// import 'package:teachers_app/pages/database.dart';
// import 'package:teachers_app/pages/teacher_dashboard.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //all the controller information

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  final nameController = TextEditingController();

  final phonenumberController = TextEditingController();

  final securitykeyController = TextEditingController();

  final uniqueIdController = TextEditingController();

  late String Department = "Department";

  ////////////////////////////////////////////////////////

  void signUserUp() async {
    // showing load circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Future addUserDetails(String name, String branch, String hometown,String? uid)async {
    //   // Call the user's CollectionReference to add a new user
    //   return await users
    //       .add({
    //     'name': name,
    //     'branch': branch,
    //     'hometown ': hometown,
    //     'uid': uid,
    //   });
    // }

    //try sign in
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString(),
        );
        debugPrint("Registration Successful");
        print("Registration Successful");

        String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
        print("current use id " + currentUserId);
        DatabaseServices(uid: currentUserId).updateUserDetails(
            nameController.text,
            emailController.text,
            uniqueIdController.text,
            phonenumberController.text,
            Department,
            securitykeyController.text

            );

        debugPrint("Registration After");
        print("Registration After");


        //try sign in
        try{
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.toString().trim(),
            password: passwordController.text.toString().trim(),
          );
          //pop the loading circle
          //Navigator.pop(context);

          // navigating to dashboard
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );

        }on FirebaseAuthException catch(e){
          //Show error message
          showErrorMessage(e.code);
        }

        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => SplashScreen()),
        // );

      } else {
        //show error message that the password does not match
        Navigator.pop(context);
        showErrorMessage('Password does not match');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      //Show error message
      showErrorMessage(e.code);
    }
  }

  //Error Message to user
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //String Department;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 50.0,
                ),

                const Icon(
                  Icons.lock,
                  size: 50,
                ),

                const SizedBox(
                  height: 25.0,
                ),

                Text('Welcome to our services',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.0)),

                const SizedBox(
                  height: 25.0,
                ),

                //Name textfield

                MyTextField(
                  controller: nameController,

                  obscureText: false,
                    hintText: "Name"

                ),
                const SizedBox(
                  height: 10.0,
                ),

                //email textfield

                const SizedBox(
                  height: 10.0,
                ),

                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(
                  height: 10.0,
                ),

                MyTextField(
                  controller: uniqueIdController,
                  hintText: "Enter Unique Id",
                  obscureText: false,
                ),



                const SizedBox(
                  height: 10.0,
                ),

                //Contact Number textfield

                MyTextField(
                  controller: phonenumberController,
                  hintText: "Contact Number",
                  obscureText: false,
                ),

                const SizedBox(
                  height: 10.0,
                ),





                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),),

                    child: DropdownButton(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      hint: Department == "Department"
                          ? const Text('Department',
                        style: TextStyle(fontSize: 17),
                      )
                          : Text(
                              Department,
                              style: TextStyle(color: Colors.black),
                            ),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.black),
                      items: ["Bio Medical Engineering",
                        "Computer Science and Engineering",
                        "Civil Engineering",
                        "Electronics and Telecommunication Engineering",
                        "Electronics and Instrumentation Engineering",
                        "Electrical Engineering",
                        "Information Technology Engineering",
                        "Industrial and Production Engineering",
                        "Mechanical Engineering",
                        "Admin"

                      ].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(
                          () {
                            Department = val!;
                          },
                        );
                      },
                    ),
                  ),
                ),




                const SizedBox(
                  height: 10.0,
                ),

                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(
                  height: 10.0,
                ),

                MyTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),

                const SizedBox(
                  height: 10.0,
                ),

                MyTextField(
                  controller: securitykeyController,
                  hintText: "Enter Security Key",
                  obscureText: true,
                ),

                const SizedBox(
                  height: 25.0,
                ),

                MyButton(
                  onTap: signUserUp,
                  text: "Register Now",
                ),

                const SizedBox(
                  height: 25.0,
                ),



                const SizedBox(
                  height: 25.0,
                ),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Google Button
                    // SquareTile(imagePath: 'lib/assets/google.png'),

                    SizedBox(
                      width: 25.0,
                    ),

                    //Apple Button
                    // SquareTile(
                    //   imagePath: 'lib/assets/apple.png',
                    // )
                  ],
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login Here',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
