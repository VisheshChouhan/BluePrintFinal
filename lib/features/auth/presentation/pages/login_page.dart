import 'package:blue_print/assets/my_color_theme.dart';
import 'package:blue_print/core/common/choice_for_roles.dart';
import 'package:blue_print/features/auth/presentation/pages/registration_page.dart';
import 'package:blue_print/features/auth/presentation/widgets/auth_bottom_text.dart';
import 'package:blue_print/features/auth/presentation/widgets/auth_button.dart';
import 'package:blue_print/features/auth/presentation/widgets/auth_text_button.dart';
import 'package:blue_print/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:blue_print/features/auth/presentation/widgets/general_text.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
                  controller: _emailController,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                  labelText: 'Password',
                  borderRadius: 8,
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: _obscureText,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChoiceForRoles(),),);
                  },
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationPage(),),);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
