import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'user_profile_model.dart';
import 'profile_state.dart';
import 'profilescreen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  Map<String, bool> _expandedQuestions = {
    "Device Related Questions": false,
    "System Related Questions": false,
    "Support Related Questions": false,
    "How do I switch off my device?": false,
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final profileState = Provider.of<ProfileState>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseDatabase.instance.ref('Users/${user.uid}').get();
      if (snapshot.exists) {
        profileState.updateProfile(
          UserProfile.fromMap(snapshot.value as Map<dynamic, dynamic>, user.email),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileState>(context).profile;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A2E47),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'FAQ\'s',
          style: TextStyle(
            color: Colors.limeAccent.shade400,
            fontWeight: FontWeight.w700,
            fontSize: isLargeScreen ? 26 : 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.03),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              child: CircleAvatar(
                radius: isLargeScreen ? 24 : 20,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: profile?.imageUrl != null
                    ? (profile!.imageUrl!.startsWith('data:image')
                    ? MemoryImage(base64Decode(profile.imageUrl!.split(',').last))
                    : NetworkImage(profile.imageUrl!) as ImageProvider)
                    : null,
                child: profile?.imageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLargeScreen ? 26 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildExpandableSection(
                    "Device Related Questions",
                    [
                      _buildQuestionTile(
                        "How can I add a new device to a room?",
                        answer: "Use the admin panel to input the device name and type, then save it.",
                        screenWidth: screenWidth,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildQuestionTile(
                        "How do I set the RGB color for a light?",
                        answer: "Tap the color button below the RGB icon and choose your desired color.",
                        screenWidth: screenWidth,
                        isLargeScreen: isLargeScreen,
                      ),
                    ],
                    screenWidth: screenWidth,
                    isLargeScreen: isLargeScreen,
                  ),
                  _buildExpandableSection(
                    "System Related Questions",
                    [
                      _buildQuestionTile(
                        "What happens if there is no internet?",
                        answer: "The app cannot sync or control devices without an active internet connection.",
                        screenWidth: screenWidth,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildQuestionTile(
                        "How does the app handle fan speed control?",
                        answer: "Fan speed is controlled via Firebase using predefined values: Low, Medium, and High.",
                        screenWidth: screenWidth,
                        isLargeScreen: isLargeScreen,
                      ),
                    ],
                    screenWidth: screenWidth,
                    isLargeScreen: isLargeScreen,
                  ),
                  _buildExpandableSection(
                    "Support Related Questions",
                    [
                      _buildQuestionTile(
                        "Why is my device not turning on from the app?",
                        answer: "Ensure the hardware is powered and properly connected to Firebase via ESP32/UNO. For this contact support team.",
                        screenWidth: screenWidth,
                        isLargeScreen: isLargeScreen,
                      ),
                      _buildQuestionTile(
                        "How to contact support?",
                        answer: "You can reach support via email ranaabubakar0320@gmail.com or mughalumar21205@gmail.com.",
                        screenWidth: screenWidth,
                        isLargeScreen: isLargeScreen,
                      ),
                    ],
                    screenWidth: screenWidth,
                    isLargeScreen: isLargeScreen,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 40 : 30,
                          vertical: isLargeScreen ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final email = 'ranaabubakar0320@gmail.com,mughalumar21205@gmail.com';
                        final subject = Uri.encodeComponent('FAQ Submission');
                        final body = Uri.encodeComponent(
                            'Hi,\n\nI have a question about the Smart Home App:\n\n[Write your question here]');
                        final Uri mailtoUrl = Uri(
                          scheme: 'mailto',
                          path: email,
                          query: 'subject=$subject&body=$body',
                        );

                        try {
                          if (await canLaunchUrl(mailtoUrl)) {
                            await launchUrl(mailtoUrl);
                          } else {
                            throw 'Could not open email app.';
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      child: Text(
                        'Ask your Question',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isLargeScreen ? 18 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandableSection(
      String title,
      List<Widget> children, {
        required double screenWidth,
        required bool isLargeScreen,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expandedQuestions[title] = !_expandedQuestions[title]!),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            margin: EdgeInsets.only(bottom: isLargeScreen ? 12 : 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLargeScreen ? 18 : 16,
                    ),
                    softWrap: true,
                  ),
                ),
                Icon(
                  _expandedQuestions[title]! ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: isLargeScreen ? 28 : 24,
                ),
              ],
            ),
          ),
        ),
        if (_expandedQuestions[title]!) ...children,
      ],
    );
  }

  Widget _buildQuestionTile(
      String question, {
        String? answer,
        required double screenWidth,
        required bool isLargeScreen,
      }) {
    final isExpanded = _expandedQuestions[question] ?? false;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expandedQuestions[question] = !isExpanded),
          child: Padding(
            padding: EdgeInsets.only(left: isLargeScreen ? 24 : 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
              margin: EdgeInsets.only(bottom: isLargeScreen ? 12 : 8),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeScreen ? 16 : 15,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                    size: isLargeScreen ? 28 : 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded && answer != null)
          Padding(
            padding: EdgeInsets.only(left: isLargeScreen ? 24 : 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
              margin: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
              ),
              child: Text(
                answer,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isLargeScreen ? 15 : 14,
                ),
                softWrap: true,
              ),
            ),
          ),
      ],
    );
  }
}