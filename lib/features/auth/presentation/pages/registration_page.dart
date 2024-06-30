import 'package:blue_print/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

import '../../../../assets/my_color_theme.dart';
import '../widgets/auth_bottom_text.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/general_text.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

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
        title: const Text("Registration",
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
                text: 'Welcome Us',
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
                labelText: 'Enter Your Email',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.email),
                obscureText: false,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Enter Your Name',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.account_circle_outlined),
                obscureText: false,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Enter Your Phone',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.phone),
                obscureText: false,
                controller: _phoneController,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Enter Your Department',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.account_balance_rounded),
                obscureText: false,
                controller: _departmentController,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                labelText: 'Enter Your Secret key',
                borderRadius: 8,
                prefixIcon: const Icon(Icons.key),
                obscureText: false,
                controller: _secretKeyController,
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
              const SizedBox(height: 16),
              AuthButton(
                borderRadius: 8,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(),),);
                },
                vertical: 16,
                buttonBackgroundColor: Theme.of(context).primaryColor,
                fontSize: 16,
                text: 'Registered',
                textColor: MyColorThemeTheme.whiteColor,
              ),
              const SizedBox(height: 16),
              AuthBottomText(
                buttonText: 'Sign In',
                generalText: 'Have an account?',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(),),);
                },
              ),
            ],
          ),
        ),
      ),
    );

  }
}
