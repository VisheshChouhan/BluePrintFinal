import 'package:blue_print/pages/home_page.dart';
import 'package:blue_print/pages/register_page.dart';
import 'package:blue_print/pages/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../assets/my_color_theme.dart';
import '../features/auth/presentation/widgets/auth_bottom_text.dart';
import '../features/auth/presentation/widgets/auth_button.dart';
import '../features/auth/presentation/widgets/auth_text_button.dart';
import '../features/auth/presentation/widgets/auth_text_field.dart';
import '../features/auth/presentation/widgets/general_text.dart';
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
      appBar: AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: const IconThemeData(
        color: MyColorThemeTheme.whiteColor,
      ),
      title: const Text("Log in",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
      // backgroundColor: Colors.grey[300],
      // body: Center(
      //   child: SafeArea(
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children:  [
      //           const SizedBox(height: 50.0,),
      //
      //
      //           const Icon(
      //             Icons.lock,
      //             size: 100,
      //           ),
      //
      //
      //           const SizedBox(height: 50.0,),
      //
      //
      //           Text('Welcome back,you\'ve been missed',
      //           style: TextStyle(
      //               color: Colors.grey[700],
      //               fontSize: 16.0)
      //           ),
      //
      //
      //           const SizedBox(height: 25.0,),
      //
      //             //email textfield
      //
      //             TextField(
      //              controller: emailController,
      //
      //              obscureText: false,
      //               decoration: const InputDecoration(
      //                 hintText: "User-Email"
      //               ),
      //            ),
      //
      //           const SizedBox(height: 10.0,),
      //
      //           TextField(
      //             controller: passwordController,
      //
      //             obscureText: true,
      //             decoration: const InputDecoration(
      //               hintText: "Password"
      //             ),
      //           ),
      //
      //
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.end,
      //             children: [
      //               Padding(
      //                 padding: EdgeInsets.symmetric(horizontal: 25.0),
      //                 child: TextButton(onPressed: (){},
      //                     child: const Text(
      //                       'Forget Password',
      //                     )),
      //               ),
      //             ],
      //           ),
      //
      //           const SizedBox(height: 10.0,),
      //
      //           ElevatedButton(onPressed: signUserIn, child: const Text(
      //             "Sign In"
      //           ))
      //             ,
      //
      //           const SizedBox(height: 25.0,),
      //
      //           Row(
      //             children: [
      //               Expanded(child: Divider(
      //                 thickness: 0.5,
      //                 color: Colors.grey[400],
      //               )),
      //
      //               Text('Or Continue with'),
      //
      //               Expanded(child: Divider(
      //                 thickness: 0.5,
      //                 color: Colors.grey[400],
      //               )),
      //             ],
      //           ),
      //
      //           const SizedBox(height: 25.0,),
      //
      //           const Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               //Google Button
      //               // SquareTile(imagePath: 'lib/assets/google.png'),
      //
      //               SizedBox(width: 25.0,),
      //
      //               //Apple Button
      //               // SquareTile(imagePath: 'lib/assets/apple.png',)
      //             ],
      //           ),
      //           SizedBox(height: 25.0,),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Text('Not a member?'),
      //               GestureDetector(
      //                 onTap: widget.onTap,
      //                 child: Text('Register Now',
      //                   style: TextStyle(
      //                     color: Colors.blue,
      //                 ),),
      //               )
      //             ],
      //           )
      //         ],
      //
      //       ),
      //     ),
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 120,),
              GeneralText(
                text: 'Welcome Back',
                fontSize: 24,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              GeneralText(
                text: 'Log in to continue',
                fontSize: 16,
                color: MyColorThemeTheme.secondaryColor,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AuthTextField(
                labelText: 'Enter Your Email/Phone',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.account_circle_rounded),
                obscureText: false,
                controller: emailController,
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
                    _obscureText ? Icons.visibility_off : Icons.visibility ,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: AuthTextButton(
                  onPressed: () {},
                  text: 'Forget Password?',
                ),
              ),
              const SizedBox(height: 16),
              AuthButton(
                borderRadius: 8,
                onPressed: signUserIn,
                vertical: 16,
                buttonBackgroundColor: Theme.of(context).primaryColor,
                fontSize: 16,
                text: 'Login',
                textColor: MyColorThemeTheme.whiteColor,
              ),
              const SizedBox(height: 16),
              AuthBottomText(
                buttonText: 'Sign Up',
                generalText: 'Don\'t have an account?',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage(onTap: togglePages,),),);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
