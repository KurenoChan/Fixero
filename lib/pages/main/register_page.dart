import 'dart:ui';

import 'package:fixero/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../services/auth_handler.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<void> _handleEmailAndPasswordRegister() async {
    if (_formKey.currentState!.validate()) {
      await AuthHandler.handleEmailAndPasswordRegister(
        context,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    await AuthHandler.handleGoogleLogin(context);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/background/bg_login_register.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blurred Overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                // color: Colors.white.withValues(alpha: 0.2),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
            ),

            // Register Form
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Heading
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 50),

                        // ============
                        // Login Fields
                        // ============
                        // 1. Username
                        TextFormField(
                          keyboardType: TextInputType.name,
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_2_rounded),
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                          ),
                          validator: (value) => Validators.validateUsername(value!),
                        ),

                        const SizedBox(height: 15),

                        // 2. Email Address
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                          ),
                          validator: (value) => Validators.validateEmail(value!),
                        ),

                        const SizedBox(height: 15),

                        // 3. Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                          ),
                          validator: (value) => Validators.validatePassword(value!),
                        ),

                        const SizedBox(height: 15),

                        // 4. Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !showConfirmPassword,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Confirm Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                          ),
                            validator: (value) => Validators.validatePassword(value!),
                        ),

                        const SizedBox(height: 30),

                        // =======
                        // Buttons
                        // =======
                        // 1. Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 70.0,
                          child: ElevatedButton(
                            onPressed: _handleEmailAndPasswordRegister,
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Or Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: Colors.white24,
                                  thickness: 1,
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.0),
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.white24,
                                        width: 1,
                                      ),
                                      right: BorderSide(
                                        color: Colors.white24,
                                        width: 1,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.white24,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.white24,
                                        width: 1,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  color: Colors.white24,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Google Login Button
                        SignInButton(
                            Buttons.google,
                            onPressed: _handleGoogleLogin,
                        ),

                        const SizedBox(height: 10.0),

                        // 3. Login Text Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                " Login",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
