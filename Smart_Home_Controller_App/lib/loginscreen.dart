import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newpro/signupscreen.dart';
import 'homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool obscurePassword = true;
  bool _isLoading = false;

  // Email validation regex
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password validation regex
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Validate email
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address (e.g., user@domain.com)';
    }
    if (email.contains('..') || email.contains('@.@') || email.contains(' ')) {
      return 'Email contains invalid characters or format';
    }
    return null;
  }

  // Validate password
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    return null;
  }

  // Show dialog with message and OK button
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0f3750),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Password Reset',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validate email
    final emailError = _validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Validate password
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful'),
          duration: Duration(seconds: 4),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMsg = 'Incorrect password provided.';
          break;
        case 'invalid-email':
          errorMsg = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMsg = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMsg = 'Too many login attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMsg = 'Invalid credentials provided.';
          break;
        default:
          errorMsg = 'Login failed: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void resetPassword() async {
    final email = emailController.text.trim();

    // Validate email
    final emailError = _validateEmail(email);
    if (emailError != null) {
      _showDialog(emailError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        // Optionally, configure actionCodeSettings for custom redirect
        // actionCodeSettings: ActionCodeSettings(
        //   url: 'https://your-app-domain.com/reset-password',
        //   handleCodeInApp: true,
        // ),
      );

      _showDialog(
        'Password reset email sent successfully. Please check your email and set a new password with at least 8 characters, including one uppercase letter, one lowercase letter, one number, and one special character (@!%*?&).',
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Error sending reset email';
      switch (e.code) {
        case 'invalid-email':
          errorMsg = 'Invalid email format';
          break;
        case 'user-not-found':
          errorMsg = 'No user found for that email';
          break;
        default:
          errorMsg = 'Error: ${e.message}';
      }

      _showDialog(errorMsg);
    } catch (e) {
      _showDialog('An unexpected error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFF0f3750)),
          padding: EdgeInsets.only(bottom: screenHeight * 0.108),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/login.png',
                    height: screenHeight * 0.4,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: screenHeight * 0.04,
                    left: screenWidth * 0.05,
                    child: Text(
                      'LOGIN',
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Colors.black,
                        fontSize: screenWidth > 600 ? 60 : 52,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Login to\nManage Your Device & Accessories',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              // Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: const Icon(Icons.email, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              // Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _isLoading ? null : loginUser,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              // Forgot Password
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : resetPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              const Center(
                child: Text(
                  "Don't have an account yet?",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}