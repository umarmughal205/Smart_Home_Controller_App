import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:newpro/main.dart';
import 'package:newpro/profile_state.dart';
import 'package:newpro/profilescreen.dart';
import 'package:newpro/termsandconditionscreen.dart';
import 'package:newpro/user_profile_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'aboutscreen.dart';
import 'adminpanelscreen.dart';
import 'bedroomscreen.dart';
import 'devicesinfoscreen.dart';
import 'faqscreen.dart';
import 'kitchenscreen.dart';
import 'livingroomscreen.dart';
import 'loginscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const mobileMaxWidth = 767;
  bool isSettingsExpanded = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final profileState = Provider.of<ProfileState>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseDatabase.instance.ref('Users/${user.uid}').get();
        if (snapshot.exists) {
          final profile = UserProfile.fromMap(snapshot.value as Map<dynamic, dynamic>, user.email);
          profileState.updateProfile(profile);

          // ✅ Check for admin
          if (user.email == 'admin@gmail.com') {
            setState(() => isAdmin = true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading profile: $e")),
          );
        }
      }
    }
  }

  Widget _buildDrawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildExpandableTile() {
    return ListTile(
      leading: const Icon(Icons.settings, color: Colors.white),
      title: const Text("Settings", style: TextStyle(color: Colors.white)),
      trailing: Icon(
        isSettingsExpanded ? Icons.expand_less : Icons.expand_more,
        color: Colors.white,
      ),
      onTap: () => setState(() => isSettingsExpanded = !isSettingsExpanded),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= mobileMaxWidth;
    final profile = Provider.of<ProfileState>(context).profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0A2E47),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Smart Homie',
          style: TextStyle(
            color: Colors.limeAccent.shade400,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              child: CircleAvatar(
                radius: 20,
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
      drawer: Drawer(
        backgroundColor: const Color(0xFF48707A),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30, left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/sidebar_logo.png', height: 50, width: 50),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfilePage()),
                          ),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.grey.shade800,
                                backgroundImage: profile?.imageUrl != null
                                    ? (profile!.imageUrl!.startsWith('data:image')
                                    ? MemoryImage(base64Decode(profile.imageUrl!.split(',').last))
                                    : NetworkImage(profile.imageUrl!) as ImageProvider)
                                    : null,
                                child: profile?.imageUrl == null
                                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(child: Text(profile?.userName ?? 'User', style: const TextStyle(fontSize: 18, color: Colors.white))),
                      Center(child: Text(profile?.userEmail ?? 'Smart User', style: const TextStyle(color: Colors.white70))),
                      const Divider(color: Colors.white54, height: 30, thickness: 0.5),
                      if (isAdmin)
                        _buildDrawerTile(Icons.admin_panel_settings, "Admin Panel", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboardScreen()));
                        }),
                      _buildDrawerTile(Icons.home, "Home", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                      }),
                      _buildExpandableTile(),
                      if (isSettingsExpanded) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: _buildDrawerTile(Icons.person, "Profile", () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: _buildDrawerTile(Icons.devices_other, "Devices Info", () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => DevicesInfoScreen()));
                          }),
                        ),
                      ],
                      _buildDrawerTile(Icons.help_outline, "FAQ", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FaqScreen()));
                      }),
                      _buildDrawerTile(Icons.article, "Terms & Conditions", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TermsAndConditionsScreen()));
                      }),
                      _buildDrawerTile(Icons.info, "About", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
                      }),
                      _buildDrawerTile(Icons.logout, "Log out", () async {
                        try {
                          FirebaseAuth.instance.signOut();
                          if (!mounted) return;

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                                (route) => false,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Logout failed. Please try again.")),
                          );
                          debugPrint("Logout error: $e");
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white54, height: 0.5),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Developed by BSE-2118 (Project ID)",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            child: Column(
              children: [
                if (isMobile) _buildMobileCards() else _buildDesktopCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards() {
    return Expanded(
      child: ListView(
        children: const [
          RoomCard(title: "Bed Room", imageUrl: "assets/images/bedroom.jpeg"),
          SizedBox(height: 30),
          RoomCard(title: "Kitchen", imageUrl: "assets/images/kitchen.jpg"),
          SizedBox(height: 30),
          RoomCard(title: "Living Room", imageUrl: "assets/images/living_room.webp"),
        ],
      ),
    );
  }

  Widget _buildDesktopCards() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Expanded(child: RoomCard(title: "Bed Room", imageUrl: "assets/images/bedroom.jpeg")),
          SizedBox(width: 32),
          Expanded(child: RoomCard(title: "Kitchen", imageUrl: "assets/images/kitchen.jpg")),
          SizedBox(width: 32),
          Expanded(child: RoomCard(title: "Living Room", imageUrl: "assets/images/living_room.webp")),
        ],
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const RoomCard({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Bed Room') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BedRoomScreen()));
        }
        if (title == 'Kitchen') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => KitchenScreen()));
        }
        if (title == 'Living Room') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LivingRoomScreen()));
        }
      },
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
          ],
        ),
        alignment: title == "Kitchen" ? Alignment.topLeft : Alignment.topRight,
        padding: title == "Kitchen"
            ? const EdgeInsets.only(left: 20, top: 20)
            : const EdgeInsets.only(right: 20, top: 20),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
      ),
    );
  }
}