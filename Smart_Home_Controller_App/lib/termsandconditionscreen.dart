import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2E47),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Terms & Conditions',
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
              SectionTitle('1. Introduction'),
              SectionText(
                  'A Smart Homie App is an integrated platform that automates and controls home devices to enhance convenience and comfort.\nYou should agree to the following terms and conditions.'),

              SectionTitle('2. User Responsibilities'),
              SectionText(
                  'You are responsible for keeping your account credentials secure. Any unauthorized access to your smart home devices is your responsibility.'),

              SectionTitle('3. Device Compatibility'),
              SectionText(
                  'This app works with supported smart home devices. Compatibility with third-party devices is not guaranteed.'),

              SectionTitle('4. Data & Privacy'),
              SectionText(
                  'We respect your privacy. Your personal and device data are stored securely and not shared without your consent.'),

              SectionTitle('5. Limitations'),
              SectionText(
                  'The app is provided "as-is". We are not liable for any damage caused by improper use of devices through the app.'),

              SectionTitle('6. Updates & Changes'),
              SectionText(
                  'We may update the app and its terms at any time. Continued use after updates implies acceptance of the new terms.'),

              SectionTitle('7. Contact Us'),
              SectionText(
                  'If you have any questions or issues, contact our support team at ranaabubakar@gmail.com or mughalumar21205@gmail.com.'),

              SizedBox(height: 30),
              Center(
                child: Text(
                  '© 2025 Smart Homie\nAll rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
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
