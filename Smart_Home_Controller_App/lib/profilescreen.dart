import 'package:flutter/material.dart';
import 'package:newpro/profile_state.dart';
import 'package:newpro/user_profile_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'loginscreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('Users');
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileState>(context).profile;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0f3750),
      appBar: AppBar(
        title: const Text('Profile',style: TextStyle(
          color: Colors.limeAccent,
          fontWeight: FontWeight.w700,
          fontSize: 22,),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showImageUpdateDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: profile?.imageUrl != null
                        ? (profile!.imageUrl!.startsWith('data:image')
                        ? MemoryImage(base64Decode(profile.imageUrl!.split(',').last))
                        : NetworkImage(profile.imageUrl!) as ImageProvider)
                        : null,
                    child: profile?.imageUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            _buildProfileField(
              label: 'Username',
              value: profile?.userName ?? 'User',
              icon: Icons.person,
              onEdit: () => _showUsernameEditDialog(profile?.userName ?? 'User'),
            ),
            SizedBox(height: screenHeight * 0.025),
            _buildProfileField(
              label: 'Email',
              value: profile?.userEmail ?? 'Smart User',
              icon: Icons.email,
              onEdit: null, // Disabled email editing
            ),
            SizedBox(height: screenHeight * 0.04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: value),
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    suffixIcon: onEdit != null
                        ? IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: onEdit,
                    )
                        : null,
                    prefixIcon: Icon(icon, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUsernameEditDialog(String currentUsername) {
    final user = _auth.currentUser;
    if (user == null) return;

    final controller = TextEditingController(text: currentUsername);
    final profileState = Provider.of<ProfileState>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f3750),
        title: const Text('Edit Username', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New Username',
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.0),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.0),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
            onPressed: () async {
              if (controller.text.isEmpty) return;
              setState(() => _isLoading = true);

              try {
                await _dbRef.child(user.uid).update({'username': controller.text});

                profileState.updateProfile(
                  UserProfile(
                    imageUrl: profileState.profile?.imageUrl,
                    userName: controller.text,
                    userEmail: profileState.profile?.userEmail ?? 'Smart User',
                  ),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Username updated successfully")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageUpdateDialog() async {
    final user = _auth.currentUser;
    if (user == null) return;

    Uint8List? selectedImageBytes;
    final profileState = Provider.of<ProfileState>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f3750),
        title: const Text('Update Profile Image', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    final bytes = kIsWeb
                        ? await pickedFile.readAsBytes()
                        : await io.File(pickedFile.path).readAsBytes();
                    setState(() => selectedImageBytes = bytes);
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: selectedImageBytes != null
                      ? MemoryImage(selectedImageBytes!)
                      : profileState.profile?.imageUrl != null
                      ? (profileState.profile!.imageUrl!.startsWith('data:image')
                      ? MemoryImage(base64Decode(profileState.profile!.imageUrl!.split(',').last))
                      : NetworkImage(profileState.profile!.imageUrl!) as ImageProvider)
                      : null,
                  child: selectedImageBytes == null && profileState.profile?.imageUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Tap image to change', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
            onPressed: () async {
              if (selectedImageBytes != null) {
                setState(() => _isLoading = true);
                try {
                  final base64Image = 'data:image/png;base64,${base64Encode(selectedImageBytes!)}';
                  await _dbRef.child(user.uid).update({'image': base64Image});
                  profileState.updateProfile(
                    UserProfile(
                      imageUrl: base64Image,
                      userName: profileState.profile?.userName ?? 'User',
                      userEmail: profileState.profile?.userEmail ?? 'Smart User',
                    ),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile image updated")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
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
  }

  @override
  void dispose() {
    super.dispose();
  }
}