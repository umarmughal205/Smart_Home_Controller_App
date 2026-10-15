import 'package:flutter/material.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2E47),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.limeAccent.shade400,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SectionTitle('Smart Homie (Smart Home Controller System)'),
              SectionText(
                  'Smart Homie is an intuitive IoT-based mobile application that allows users to control and monitor their home appliances like lights, fans, RGB lights, and more from anywhere.'),

              SectionTitle('Key Features'),
              SectionText(
                  '• Real-time device control\n• RGB light customization\n• Secure Firebase authentication\n• Device usage tracking\n• Easy user interface'),

              SectionTitle('Purpose'),
              SectionText(
                  'The project aims to develop a centralized smart home system to automate comfort and safety. It provides a seamless, user-friendly platform for efficient control of home devices.'),

              SectionTitle('Technology Stack'),
              SectionText(
                  '• Flutter (Frontend)\n• Firebase (Authentication & Realtime Database)\n• IoT Integration with Arduino UNO & ESP32\n• State Management using Provider'),

              SectionTitle('Developer'),
              SectionText(
                  'This application was developed by:\n• Abubakar (BSE21203)\n• Muhammad Umar Afzal (BSE21205)\nas part of a final year IoT-based project.'),

              SectionTitle('Version'),
              SectionText('4.3.0'),

              SizedBox(height: 30),
              Center(
                child: Text(
                  '© 2025 Smart Homie\nAll rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SectionText extends StatelessWidget {
  final String text;
  const SectionText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 15,
        height: 1.5,
      ),
    );
  }
}
