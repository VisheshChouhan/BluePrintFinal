import 'package:blue_print/pages/home_page.dart';
import 'package:blue_print/pages/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:teachers_app/models/MyButton.dart';
// import 'package:teachers_app/models/my_textfield.dart';
// import 'package:teachers_app/models/squareTile.dart';
// import 'package:teachers_app/pages/teacher_dashboard.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({
    super.key,
    required this.onTap
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void signUserIn() async {

    // showing load circle
    showDialog(
      context: context,
      builder: (context){
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

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
  }

  //Error Message to user
  void showErrorMessage(String message){
    showDialog(context: context,
      builder: (context) {
        return AlertDialog(title: Text(message),);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children:  [
                const SizedBox(height: 50.0,),


                const Icon(
                  Icons.lock,
                  size: 100,
                ),


                const SizedBox(height: 50.0,),


                Text('Welcome back,you\'ve been missed',
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16.0)
                ),


                const SizedBox(height: 25.0,),

                  //email textfield

                  TextField(
                   controller: emailController,

                   obscureText: false,
                    decoration: const InputDecoration(
                      hintText: "User-Email"
                    ),
                 ),

                const SizedBox(height: 10.0,),

                TextField(
                  controller: passwordController,

                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Password"
                  ),
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextButton(onPressed: (){},
                          child: const Text(
                            'Forget Password',
                          )),
                    ),
                  ],
                ),

                const SizedBox(height: 10.0,),

                ElevatedButton(onPressed: signUserIn, child: const Text(
                  "Sign In"
                ))
                  ,

                const SizedBox(height: 25.0,),

                Row(
                  children: [
                    Expanded(child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    )),

                    Text('Or Continue with'),

                    Expanded(child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    )),
                  ],
                ),

                const SizedBox(height: 25.0,),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Google Button
                    // SquareTile(imagePath: 'lib/assets/google.png'),

                    SizedBox(width: 25.0,),

                    //Apple Button
                    // SquareTile(imagePath: 'lib/assets/apple.png',)
                  ],
                ),
                SizedBox(height: 25.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member?'),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text('Register Now',
                        style: TextStyle(
                          color: Colors.blue,
                      ),),
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
