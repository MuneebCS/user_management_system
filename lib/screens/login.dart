import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_management_system/screens/signup.dart';
import 'package:user_management_system/widgets/custom_button.dart';
import 'package:user_management_system/widgets/custom_textfield.dart';

import '../provider/auth_povider.dart';
import 'homepage.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 100,
                ),
                Text(
                  "Login",
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 24),
                _form(authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(AuthenticationProvider authProvider) {
    return Form(
      child: Column(
        children: [
          CustomTextField(
            controller: authProvider.emailController,
            hintText: 'Email',
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: authProvider.passwordController,
            hintText: 'Password',
            obscureText: _obscurePassword,
            keyboardType: TextInputType.text,
            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 24.0),
          CustomButton(
            text: "Login",
            onPressed: () async {
              await authProvider.login();

              if (authProvider.errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.errorMessage),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            },
          ),
          const SizedBox(height: 24.0),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "New User? ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),
                    );
                  },
                  child: Text(
                    "Sign up Here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
