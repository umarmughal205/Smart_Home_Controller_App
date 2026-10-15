import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.ref('Users');

  // Email validation regex
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Username validation regex
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,}$');

  // Password validation regex
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Validate username
  String? _validateUsername(String username) {
    if (username.isEmpty) {
      return 'Please enter a username';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (!username.startsWith(RegExp(r'[a-zA-Z]'))) {
      return 'Username must start with a letter';
    }
    if (!_usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

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
      return 'Please enter a password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(password)) {
      return 'Password must contain at least one special character (@!%*?&)';
    }
    return null;
  }

  void registerUser() async {
    if (_isLoading) return;

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validate username
    final usernameError = _validateUsername(username);
    if (usernameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(usernameError),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

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

    // Validate confirm password
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email is already in use
      final signInMethods = await auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already registered'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Create user with Firebase Authentication
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;

      if (uid != null) {
        // Store user data in Firebase Realtime Database
        const dummyImage = 'data:image/png;base64,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';

        await dbRef.child(uid).set({
          'username': username,
          'email': email,
          'image': dummyImage,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User Registered Successfully'),
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMsg = 'The email address is not valid';
          break;
        case 'weak-password':
          errorMsg = 'The password is too weak';
          break;
        default:
          errorMsg = 'Registration failed: ${e.message}';
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(color: Color(0xFF0f3750)),
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
                        'SIGN UP',
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
                    'Sign Up To\nManage Your Device & Accessories',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                // Username
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      hintText: 'Username',
                      hintStyle: const TextStyle(color: Colors.white70),
                      suffixIcon: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                // Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible = !isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Register Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _isLoading ? null : registerUser,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                          'Register',
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
                const SizedBox(height: 20),
                // Login Link
                const Center(
                  child: Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Login Here',
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
      ),
    );
  }
}