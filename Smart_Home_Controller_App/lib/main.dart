import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newpro/profile_state.dart';
import 'loginscreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart'; // This is auto-generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // if (kIsWeb) {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // } else {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // }

  runApp(
    ChangeNotifierProvider(
    create: (context) => ProfileState(),
    child: const SmartHomieApp(),
  ),);
}

class SmartHomieApp extends StatelessWidget {
  const SmartHomieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Smart Homie',
      theme: ThemeData(
        fontFamily: 'Roboto', // Modern font (can replace with Google Fonts Inter if added)
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //network image
  /*Widget _buildImage(double maxWidth) {
    // Using placehold.co as per instructions with alt text in semantics
    return Semantics(
      label:
      'Isometric illustration of a modern smart home with rooms including living area, bedroom and kitchen in a hexagonal layout',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          // Placeholder image: 400x350 with a dark background and bright colored door to mimic original
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTeyZHMlE33EpxXWLGGO6U4jgsGAe7flRAo6Q&s',
          width: maxWidth,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: maxWidth,
              height: maxWidth * 0.875,
              color: Colors.blueGrey.shade900,
              alignment: Alignment.center,
              child: Text(
                'Image failed to load',
                style: TextStyle(color: Colors.red.shade200),
              ),
            );
          },
        ),
      ),
    );
  }*/
  //asset image
  Widget _buildImage(double maxWidth) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.1, end: 1.0)
          .animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)),
      child: Semantics(
        label:
        'Isometric illustration of a modern smart home with rooms including living area, bedroom and kitchen in a hexagonal layout',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'assets/images/splash_logo.png',
            width: maxWidth,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: maxWidth,
                height: maxWidth * 0.875,
                color: Colors.blueGrey.shade900,
                alignment: Alignment.center,
                child: Text(
                  'Image failed to load',
                  style: TextStyle(color: Colors.red.shade200),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildText(BuildContext context, bool isMobile) {
    const specialGreen = Color(0xFF7CE214);
    const specialYellow = Color(0xFFE4E20F);

    TextStyle greenStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: isMobile ? 28 : 36,
      color: specialGreen,
      fontFamily: 'Courier New', // playful font as in screenshot
    );

    TextStyle yellowStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: isMobile ? 28 : 36,
      color: specialYellow,
      fontFamily: 'Courier New',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: isMobile
                ? greenStyle.copyWith(fontSize: 28)
                : greenStyle.copyWith(fontSize: 36),
            children: [
              TextSpan(text: 'Wel', style: greenStyle),
              TextSpan(text: 'come', style: yellowStyle),
              const TextSpan(text: '\n'),
              TextSpan(text: 'to', style: greenStyle),
              const TextSpan(text: '\n'),
              TextSpan(text: 'Sma', style: greenStyle),
              TextSpan(text: 'rt Homie', style: yellowStyle),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Easily Control Your Home',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Manage your home from anytime, anywhere.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('SplashScreen is building'); // DEBUG LINE
    // Responsive breakpoints based on width
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0f3750), // Dark blue gradient base color
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? width * 0.9 : 800,
                ),
                child: isMobile
                    ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildImage(width * 0.7),
                      const SizedBox(height: 48),
                      _buildText(context, isMobile),
                    ],
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(flex: 6, child: _buildImage(350)),
                    const SizedBox(width: 48),
                    Flexible(flex: 5, child: _buildText(context, isMobile)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

