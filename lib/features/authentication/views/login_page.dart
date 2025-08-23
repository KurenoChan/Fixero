import 'dart:ui';

import 'package:fixero/features/authentication/views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../utils/validators/validators.dart';
import '../controllers/auth_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool showPassword = false;

  Future<void> _handleEmailAndPasswordLogin() async {
    if (_formKey.currentState!.validate()) {
      await AuthHandler.handleEmailAndPasswordLogin(
        context,
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    await AuthHandler.handleGoogleLogin(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),

            // Login Form
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
                          "Login",
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
                        // 1. Email Address
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
                          validator: (value) =>
                              Validators.validateEmail(value!),
                        ),

                        const SizedBox(height: 15),

                        // 2. Password
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
                          validator: (value) =>
                              Validators.validatePassword(value!),
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            // style: ButtonStyle(
                            //   backgroundColor: WidgetStateProperty.all<Color>(Colors.white30),
                            // ),
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // =======
                        // Buttons
                        // =======
                        // 1. Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 70.0,
                          child: ElevatedButton(
                            onPressed: _handleEmailAndPasswordLogin,
                            child: const Text(
                              'Login',
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

                        // 3. Register Text Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
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
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                " Register",
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
