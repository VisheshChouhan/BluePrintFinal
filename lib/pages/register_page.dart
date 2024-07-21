import 'package:blue_print/pages/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../assets/my_color_theme.dart';
import '../features/auth/presentation/widgets/auth_bottom_text.dart';
import '../features/auth/presentation/widgets/auth_button.dart';
import '../features/auth/presentation/widgets/auth_text_field.dart';
import '../features/auth/presentation/widgets/general_text.dart';
import '../helper_classes/database.dart';
import 'login_page.dart';


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

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  bool showLoginPage = true;

  //toggle between the login page and register page

  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

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
            nameController.text.trim(),
            emailController.text.trim(),
            uniqueIdController.text.toUpperCase().trim(),
            phonenumberController.text.trim(),
            Department.trim(),
            securitykeyController.text.trim()

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
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(
          color: MyColorThemeTheme.whiteColor,
        ),
        title: const Text("Registration Form",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GeneralText(
                text: 'Welcome',
                fontSize: 24,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              GeneralText(
                text: 'Create new account',
                fontSize: 16,
                color: MyColorThemeTheme.secondaryColor,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AuthTextField(
                labelText: 'Enter Your Name',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.account_circle_outlined),
                obscureText: false,
                controller: nameController, hintText: 'Name',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Enter Your Email',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.email),
                obscureText: false,
                controller: emailController, hintText: 'Email',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Enter Your Unique ID',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.public_off),
                obscureText: false,
                controller: uniqueIdController, hintText: 'Unique ID',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Enter Your Phone',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.phone),
                obscureText: false,
                controller: phonenumberController, hintText: 'Phone',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Password',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.lock),
                obscureText: _obscureText,
                controller: passwordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ), hintText: 'Password',
              ),
              const SizedBox(height: 16,),
              AuthTextField(
                labelText: 'Confirm Password',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.lock),
                obscureText: _obscureText,
                controller: confirmPasswordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ), hintText: 'Confirm Password',
              ),
              const SizedBox(height: 16,),
              AuthTextField(
                labelText: 'Enter Your Security key',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.key),
                obscureText: false,
                controller: securitykeyController, hintText: 'Secret Key',
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 53,
                child: Center(
                  child: DropdownButton(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    hint: Department == "Department"
                        ? const Text('Department',
                      style: TextStyle(fontSize: 17,color: Colors.black87),
                    )
                        : Text(
                      Department,
                      style: TextStyle(color: Colors.black),
                    ),
                    isDense: true,
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
              const SizedBox(height: 16),
              AuthButton(
                borderRadius: 8,
                onPressed: signUserUp,
                vertical: 16,
                buttonBackgroundColor: Theme.of(context).primaryColor,
                fontSize: 16,
                text: 'Register',
                textColor: MyColorThemeTheme.whiteColor,
              ),
              const SizedBox(height: 16),
              AuthBottomText(
                buttonText: 'Sign In',
                generalText: 'Have an account?',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(onTap: togglePages,),),);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
